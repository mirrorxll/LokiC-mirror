# frozen_string_literal: true

module LokiC
  module Story
    class BlobToFile # :nodoc:
      def initialize(story)
        @story = story
        File.open("#{Rails.root}/lib/loki_c/story/code/#{@story.filename}.rb", 'wb') do |file|
          file.write(@story.code.download)
        end
      end
    end
  end
end
