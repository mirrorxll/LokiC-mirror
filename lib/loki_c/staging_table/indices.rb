# frozen_string_literal: true

module LokiC
  module StagingTable
    module Indices
      def self.transform(indices)
        grouped = indices.group_by { |idx| idx['Key_name'] }
                         .reject { |k, _v| k.downcase.eql?('primary') }

        grouped.each_with_object({}) do |(name, columns), obj|
          obj[SecureRandom.hex(3)] = {
            name: name,
            columns: columns.sort_by { |c| c['Seq_in_index'] }.map { |c| c['Column_name'] },
            unique: columns.first['Non_unique'].zero?
          }
        end
      end
    end
  end
end
