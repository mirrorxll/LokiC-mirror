# frozen_string_literal: true

module MiniLokiC
  module Creation
    # select staging records and preparation them
    # for create story type samples
    class StagingRecords
      # modified constructor for
      # improving codes readable
      def self.[](staging_table, options = {})
        new(staging_table, options)
      end

      def each
        raise ArgumentError, 'No block is given' unless block_given?

        loop do
          select =
            if @options[:ids]
              Table.rows_by_ids(@staging_table, @options)
            else
              Table.rows_by_last_iteration(@staging_table, @options)
            end

          break if select.empty?

          select.each { |row| yield(row) }
        end
      end

      private

      def initialize(staging_table, options)
        @staging_table = staging_table
        @options = options
      end
    end
  end
end
