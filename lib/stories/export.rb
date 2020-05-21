# frozen_string_literal: true

module Stories
  class Export
    def initialize(pl_client, story_type, options)
      @pl_client = pl_client
      @story_type = story_type
      @options = options
    end

    def export!
      @story_type.export_configurations.each do |config|

      end
    end
  end
end
