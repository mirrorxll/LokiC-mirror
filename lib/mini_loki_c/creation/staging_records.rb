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

        select =
          if @options[:ids]
            Table.rows_by_ids(@staging_table, @options)
          else
            Table.rows_by_iteration(@staging_table, @options)
          end

        story_type = @options[:iteration].respond_to?(:story_type)
        select.each_with_index do |row, i|
          break if story_type && (i % 100).zero? && @options[:iteration].story_type.sidekiq_break.reload.cancel

          yield(HashWithIndifferentAccess.new(row))
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
