# frozen_string_literal: true

module LokiC
  module Story
    class Creation < BlobToFile # :nodoc:
      def self.run(story, options = {})
        file_to_require(story)
        pid = fork do
          require_relative "#{Rails.root}/lib/loki_c/story/code/#{@story.filename}.rb"
          creation(options)
        end

        Process.wait(pid)
      end
    end
  end
end
