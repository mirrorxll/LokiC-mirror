# frozen_string_literal: true

require 'loki_c/story/population.rb'

module LokiC
  module Story
    class BlobToFile # :nodoc:
      def initialize(story_id)
        @filename = "#{SecureRandom.hex(10)}.rb"
        File.open("#{Rails.root}/lib/loki_c/story/code/#{@filename}", 'wb') do |file|
          file.write(Story.find(story_id).code.download)
        end
      end
    end
  end
end
