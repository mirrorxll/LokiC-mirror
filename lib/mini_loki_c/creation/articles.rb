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

      def insert(article)
        raise ArgumentError, "staging_row_id can't be blank!" if article[:staging_row_id].nil?

        Article.create!(
          {
            factoid_type: @iteration.factoid_type,
            iteration: @iteration,
            staging_row_id: article[:staging_row_id],
            sampled: @sampled,
            output: ArticleOutput.new(body: article[:body])
          }
        )
      end
    end
  end
end
