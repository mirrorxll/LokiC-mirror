# frozen_string_literal: true

module LokiC
  module StagingTable
    module Indices
      def self.transform(index)
        {
          name: index.first['Key_name'],
          columns: index.sort_by { |c| c['Seq_in_index'] }.map { |c| c['Column_name'] },
        }
      end
    end
  end
end
