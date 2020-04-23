# frozen_string_literal: true

require_relative 'iteration/export_iteration'

module MiniLokiC
  module Story
    module Creation
      module Iteration # :nodoc:
        def self.find_or_create(staging_table)
          iteration = StoryIteration.new(staging_table)

          id = if iteration.last && iteration.last['status'].zero?
                 iteration.last['id']
               else
                 iteration.create
               end

          iteration.close_connection
          id
        end

        def self.success(staging_table)
          iteration = StoryIteration.new(staging_table)
          iteration.update_status
          iteration.close_connection
        end
      end
    end
  end
end