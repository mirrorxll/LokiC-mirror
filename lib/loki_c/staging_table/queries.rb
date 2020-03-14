# frozen_string_literal: true

module LokiC
  module StagingTable
    module Queries
      def self.column_list(t_name)
        "show columns from `#{t_name}` where Field not in ('id', 'story_created', "\
        "'client_id', 'client_name', 'project_id', 'project_name', 'publish_on');"
      end
    end
  end
end