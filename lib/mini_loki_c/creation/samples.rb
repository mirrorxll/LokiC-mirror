# frozen_string_literal: true

module MiniLokiC
  module Creation
    # insert created samples to samples table
    class Samples
      def initialize(staging_table, options)
        @sampled = options[:sampled].present?
        @staging_table = staging_table
        @s_type = StagingTable.find_by(name: @staging_table).story_type
        @iteration = @s_type.iteration
        @export_configs = @s_type.export_configurations.joins(:publication)
      end

      def insert(sample)
        @raw_sample = sample
        @iteration.samples.create!(sample_params)
        Table.sample_set_as_created(@staging_table, sample[:staging_row_id])
      end

      private

      # prepare sample to inserting
      def sample_params
        config = export_config
        time_frame = TimeFrame.find_by(frame: @raw_sample[:time_frame].downcase)
        publication = config.publication
        client = publication.client

        {
          story_type: @s_type,
          output: output,
          staging_row_id: @raw_sample[:staging_row_id],
          client: client,
          publication: publication,
          organization_ids: @raw_sample[:organization_ids],
          time_frame: time_frame,
          export_configuration: config,
          sampled: @sampled
        }
      end

      def output
        Output.new(
          headline: @raw_sample[:headline],
          teaser: @raw_sample[:teaser],
          body: basic_html_substitutions_body
        )
      end

      def export_config
        export_config = @export_configs.find_by(
          publications: {
            pl_identifier: @raw_sample[:publication_id]
          }
        )
        return export_config if export_config

        raise ArgumentError,
              'There is a publication in the staging table '\
              'for which no export configuration has been created. '\
              'Please click [create export configurations]'
      end

      # wrap to HTML tags
      def basic_html_substitutions_body
        @raw_sample[:body].gsub!(/(?:^|\n\n|\n\t)(.+)(?:\n\n*|\n\t|$)/, '<p>\1</p>')
        @raw_sample[:body].gsub!(%r{(<svg .*?/svg>)}) { |svg| svg.gsub(%r{</?p>}, '') }

        "<html><head><title></title><style></style></head><body>#{@raw_sample[:body]}</body></html>"
      end
    end
  end
end
