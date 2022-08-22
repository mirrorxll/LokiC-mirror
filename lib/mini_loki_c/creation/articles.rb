# frozen_string_literal: true

module MiniLokiC
  module Creation
    # insert created stories to stories table
    class Articles
      def initialize(staging_table, options)
        @staging_table = staging_table
        @sampled = options[:sampled]
        @iteration = options[:iteration]
      end

      def insert(factoid)
        raise ArgumentError, "staging_row_id can't be blank!" if factoid[:staging_row_id].nil?

        Factoid.create!(
          {
            factoid_type: @iteration.factoid_type,
            iteration: @iteration,
            staging_row_id: factoid[:staging_row_id],
            sampled: @sampled,
            output: FactoidOutput.new(body: factoid[:body])
          }
        )
      end
    end
  end
end
