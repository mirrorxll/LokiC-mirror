# frozen_string_literal: true

require 'loki_c/connection/mysql.rb'

module LokiC
  module Story
    class Population < BlobToFile # :nodoc:
      def initialize(story_id)
        super(story_id)
        require "loki_c/story/code/#{@filename}"
      end
    end
  end
end
