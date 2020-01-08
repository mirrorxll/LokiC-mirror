# frozen_string_literal: true

module LokiC
  module Story
    module Samples # :nodoc:
      def self.last_iteration(story)
        last_it = story.iterations.last
        if !last_it[:create_status] && last_it[:populate_status]
          story.staging_table.iteration_rows(last_it[:number])
        else
          []
        end
      end
    end
  end
end
