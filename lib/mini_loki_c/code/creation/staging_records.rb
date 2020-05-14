# frozen_string_literal: true

module MiniLokiC
  module Creation
    # select staging records and preparation them
    # for create story type samples
    class StagingRecords
      # modified constructor for
      # improving code readable
      def self.[](staging_table, options = {})
        new(staging_table, options)
      end

      def each
        raise ArgumentError, 'No block is given' unless block_given?

        loop do
          select = staging_table_rows
          break if select.empty?

          select.each { |row| yield(row) }
        end
      end

      private

      def initialize(staging_table, options)
        @mysql = Connect::Mysql.on(DB05, 'loki_storycreator')
        @query = Table.select_query(staging_table, options)
      end

      # selecting staging table rows.
      # if it wasn't passed limit in options
      # it will be select 7_000 rows.
      # it needs for optimization server's load
      def staging_table_rows
        @mysql.query(@query).to_a
      end
    end
  end
end
