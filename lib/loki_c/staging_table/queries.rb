# frozen_string_literal: true

module LokiC
  module StagingTable
    module Queries
      def self.table_columns(t_name)
        "show columns from `#{t_name}` where Field not in "\
        "('id','story_created','client_id','client_name',"\
        "'publication_id','publication_name','organization_id',"\
        "'publish_on','created_at','updated_at');"
      end

      def self.table_index(t_name)
        "show index from `#{t_name}` where Key_name = 'story_per_publication';"
      end
    end
  end
end
