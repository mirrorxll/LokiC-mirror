# frozen_string_literal: true

module Stories
  class Export
    def initialize(pl_client, story_type, options)
      @pl_client = pl_client
      @story_type = story_type
      @options = options
    end

    def export!
      if @options[:ids]
        @story_type.iteration.samples.where(id: @options[:ids]).each do |story|

        end
      else
        @story_type.export_configurations.each do |config|

        end
      end
    end

    private

    def by_ids

    end

    def all

    end
  end
end
