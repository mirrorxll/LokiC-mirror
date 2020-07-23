# frozen_string_literal: true

require_relative 'export/job_item.rb'
require_relative 'export/export_parameters.rb'
require_relative 'export/post_lead_story.rb'

module Samples
  class Export
    include JobItem
    include ExportParameters
    include PostLeadStory

    def initialize(environment)
      @pl_client = Pipeline[environment]
      @pl_replica_client = PipelineReplica[environment]
      @job_item_key = "#{environment}_job_item".to_sym
    end

    def export!(story_type)
      client_tags = story_type.client_tags
      samples(story_type).find_each { |sample| post_lead_story(sample, client_tags) }
    end

    private

    def samples(story_type)
      story_type
        .iteration.samples.joins(:export_configuration, :publication, :output)
        .order(:published_at).where(backdated: false)
        .where.not(export_configurations: { tag: nil })
    end
  end
end
