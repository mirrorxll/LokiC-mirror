# frozen_string_literal: true

require_relative 'export/post_lead_story.rb'

module Stories
  class Export
    include PostLeadStory

    def initialize(pl_client, story_type, options)
      @pl_client = pl_client
      @pl_replica_client = PipelineReplica[pl_client.environment]
      @job_item_key = "#{pl_client.environment}_job_item".to_sym
      @story_type = story_type
      @options = options
    end

    def export!
      @options[:sample_ids] ? by_ids : all
    end

    private

    def all
      stories = @story_type.iteration.samples
                           .joins(:export_configuration, :publication, :output)
                           .where(backdated: false).order(:published_at)
      stories.find_each { |story| post_lead_story(story) }
    end

    def by_ids
      stories = @story_type.iteration.samples
                           .joins(:export_configuration, :publication, :output)
                           .where(id: @options[:sample_ids]).order(:published_at)
      stories.each { |story| post_lead_story(story) }
    end
  end
end
