# frozen_string_literal: true

require_relative 'export/job_item.rb'
require_relative 'export/export_parameters.rb'
require_relative 'export/post_lead_story.rb'

module Samples
  class Export
    include JobItem
    include ExportParameters
    include PostLeadStory

    def initialize(pl_client, story_type, options)
      @pl_client = pl_client
      @pl_replica_client = PipelineReplica[pl_client.environment]
      @job_item_key = "#{pl_client.environment}_job_item".to_sym
      @story_type = story_type
      @options = options
    end

    def export!
      client_tags = @story_type.client_tags
      samples = (@options[:sample_ids] ? by_ids : all)

      samples.find_each { |sample| post_lead_story(sample, client_tags) }
    end

    private

    def all
      complete_samples
        .where(backdated: false)
        .where.not(export_configurations: { tag: nil })
    end

    def by_ids
      complete_samples
        .where(id: @options[:sample_ids])
    end

    def complete_samples
      @story_type
        .iteration.samples.joins(:export_configuration, :publication, :output).order(:published_at)
    end
  end
end
