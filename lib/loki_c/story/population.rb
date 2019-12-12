# frozen_string_literal: true

module LokiC
  module Story
    class Population < BlobToFile # :nodoc:
      def self.run(story, options = {})
        file = file_to_require(story)
        load file
        method("population_#{story.id}").call(options)
      end
    end
  end
end
