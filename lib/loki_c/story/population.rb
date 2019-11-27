# frozen_string_literal: true

# require 'loki_c/connect/mysql.rb'

module LokiC
  module Story
    class Population < BlobToFile # :nodoc:
      def initialize(story)
        super(story)
      end

      def run(*args)
        pid = fork do
          require_relative "#{Rails.root}/lib/loki_c/story/code/#{@story.filename}.rb"
          population(args)
        end

        Process.wait(pid)
      end

      def purge(*args)

      end
    end
  end
end
