# frozen_string_literal: true

module LokiC
  module StagingTable
    module Queries
      def self.table_columns(t_name)
        "show columns from `#{t_name}` where Field not in "\
        "('id', 'story_created', 'client_id', 'client_name', "\
        "'project_id', 'project_name', 'publish_on');"
      end

      def self.table_indices(t_name)
        "show index from `#{t_name}` where `Key_name` != 'PRIMARY';"
      end
    end
  end
end
