# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module ExtraArgs
        def self.stage_ids(staging_table, arg)
          query = "SELECT id FROM `#{staging_table}` WHERE #{arg};"
          Table.loki_story_creator do
            ActiveRecord::Base.connection.exec_query(query).to_a.map { |row| row['id'] }
          end
        end
      end
    end
  end
end
