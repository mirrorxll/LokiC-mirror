# frozen_string_literal: true

module Hle
  module Queries
    class Columns
      def self.added(curr_columns, modify_columns)

      end

      def self.dropped(curr_columns, modify_columns)

      end

      def self.changed(curr_columns, modify_columns)

      end

      def self.ids(columns)
        columns.keys.map { |key| key.to_s.split('_').last }.uniq
      end
    end
  end
end
