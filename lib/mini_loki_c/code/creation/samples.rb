# frozen_string_literal: true

module MiniLokiC
  module Creation
    # insert created samples to samples table
    class Samples
      def initialize(staging_table)
        @staging_table = staging_table
        @iteration = story_type.iteration
      end

      def insert(sample)
        @raw_sample = sample
        @iteration.samples.create!(sample_params)
        Table.sample_as_created(@staging_table, sample[:staging_row_id])
      end

      private

      # find story type
      def story_type
        StagingTable.find_by(name: @staging_table).story_type
      end

      def sample_params
        {
          output: output,
          staging_row_id: @raw_sample[:staging_row_id],
          publication_id: @raw_sample[:publication_id]
        }
      end

      # prepare output to inserting
      def output
        Output.create!(
          headline: @raw_sample[:headline],
          teaser: @raw_sample[:teaser],
          body: basic_html_substitutions_body
        )
      end

      # wrap to HTML tags
      def basic_html_substitutions_body
        output = @raw_sample[:body].gsub(/(?:^|\n\n|\n\t)(.+)(?:\n\n*|\n\t|$)/, '<p>\1</p>')
        "<html><head><title></title><style></style></head><body>#{output}</body></html>"
      end
    end
  end
end
