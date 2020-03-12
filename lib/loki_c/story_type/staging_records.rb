# frozen_string_literal: true

module LokiC
  module StoryType
    module StagingRecords # :nodoc:
      def self.last_iteration(story_type)
        last_it = story_type.iterations.last
        if !last_it[:create_status] && last_it[:populate_status]
          story_type.staging_table.rows(last_it[:number])
        else
          []
        end
      end
    end
  end
end
