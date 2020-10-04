# frozen_string_literal: true

require_relative 'export/lead_story_post.rb'
require_relative 'export/story_update.rb'

module Samples
  class ExportToPl
    include Export::LeadStoryPost
    include Export::StoryUpdate

    def initialize(environment)
      @environment = environment
      @pl_client = Pipeline[environment]
      @pl_id_key = "pl_#{environment}_id".to_sym
    end

    def export!(story_type)
      @story_type = story_type
      iteration_samples = samples(story_type)
      threads = (iteration_samples.count / 75_000.0).ceil + 1

      iteration_samples.find_in_batches(batch_size: 10_000) do |samples|
        samples_to_export = samples.to_a
        semaphore = Mutex.new

        threads = Array.new(threads) do
          Thread.new do
            pl_rep_client = PipelineReplica[@environment]

            loop do
              sample = semaphore.synchronize { samples_to_export.shift }
              break if sample.nil?

              lead_story_post(sample, pl_rep_client)
            rescue Samples::Error => e
              target = story_type.developer.slack.identifier
              if target
                message = "*##{story_type.id} #{story_type.name}* -- #{e}\n"\
                          'Sample was skipped. *Export continued...*'

                SlackNotificationJob.perform_later(target, message)
              end
            end

            pl_rep_client.close
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
