# frozen_string_literal: true

module LokiC
  module StagingTable
    class Columns # :nodoc:
      # name, type
      # def self.added(curr_columns, modify_columns)
      #   modify_columns.map do |m_c|
      #     curr_columns.any? { |c_c| c_c['id'].eql?(m_c[:id]) } ? nil : m_c
      #   end.compact
      # end
      #
      # # name
      # def self.dropped(curr_columns, modify_columns)
      #   curr_columns.map do |c_c|
      #     modify_columns.none? { |m_c| m_c[:id].eql?(c_c['id']) } ? c_c : nil
      #   end.compact
      # end
      #
      # def self.changed(curr_columns, modify_columns)
      #   ids = Ids.from_pure(curr_columns) & Ids.from_pure(modify_columns)
      #
      #   ids.map do |id|
      #     c_col = curr_columns.find { |c| c['id'].eql?(id) }
      #     m_col = modify_columns.find { |m| m[:id].eql?(id) }
      #     next if c_col.symbolize_keys.eql?(m_col)
      #
      #     {
      #       old_name: c_col['name'],
      #       new_name: m_col[:name],
      #       new_type: m_col[:type]
      #     }
      #   end.compact
      # end

      def self.transform_init(columns)
        cols = columns.map do |_id, column|
          opts = (column[:opts] || {})
          { column[:name] => [column[:type], opts] }
        end

        cols.count.positive? ? cols.reduce(:merge) : {}
      end

      # key - column name
      # value - column type
      def self.transform_exist(columns)
        return {} if columns.empty?

        columns.map { |col| { col[0] => col[1] } }.reduce(:merge)
      end

      private

      def self.sql_to_ar(type)

      end
    end
  end
end
