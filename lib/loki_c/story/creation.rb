# frozen_string_literal: true

module LokiC
  module Story
    class Creation < BlobToFile # :nodoc:
      def initialize(story_id)
        super(story_id)
      end
    end
  end
end