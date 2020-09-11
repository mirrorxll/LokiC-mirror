# frozen_string_literal: true

require_relative 'export/job_item.rb'
require_relative 'export/export_parameters.rb'
require_relative 'export/lead_story_post.rb'
require_relative 'export/story_update.rb'

module Samples
  class ExportToPl
    include Export::JobItem
    include Export::ExportParameters
    include Export::LeadStoryPost
    include Export::StoryUpdate

    def initialize(environment)
      @pl_client = Pipeline[environment]
      @pl_replica_client = PipelineReplica[environment]
      @job_item_key = "#{environment}_job_item".to_sym
      @pl_id_key = "pl_#{environment}_id".to_sym
    end

    def export!(story_type)
      @story_type = story_type
      client_tags = story_type.client_tags

      samples(story_type).find_in_batches(batch_size: 10_000) do |samples|
        samples_to_export = samples.to_a
        semaphore = Mutex.new

        threads = Array.new(20) do
          Thread.new do
            loop do
              sample = semaphore.synchronize { samples_to_export.shift }
              break if sample.nil?

              story_id = lead_story_post(sample, client_tags)
              organization_ids = sample.organization_ids.delete('[ ]').split(',')
              story_update(story_id, organization_ids)

              sample.update(@pl_id_key => story_id)
            end
          end
        end

        threads.each(&:join)
      end
    end

    private

    def samples(story_type)
      story_type.iteration.samples.where(@pl_id_key => nil)
                .joins(:export_configuration, :publication, :output)
                .order(:published_at).where(backdated: false)
                .where.not(export_configurations: { tag: nil })
    end
  end
end
