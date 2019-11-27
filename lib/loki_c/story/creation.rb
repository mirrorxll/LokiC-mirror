# frozen_string_literal: true

module LokiC
  module Story
    class Creation < BlobToFile # :nodoc:
      def initialize(story_id)
        super(story_id)
      end

      def run(*args)
        pid = fork do
          load "loki_c/story/code/#{@filename}.rb"
          creation(args)
        end

        Process.wait(pid)
      end
    end
  end
end
