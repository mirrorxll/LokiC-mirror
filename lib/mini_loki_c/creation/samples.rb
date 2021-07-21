# frozen_string_literal: true

module MiniLokiC
  module Creation
    # insert created samples to samples table
    class Samples
      def initialize(staging_table, options)
        @staging_table = staging_table
        @sampled = !!options[:sampled]
        @iteration = options[:iteration]
        @story_type = @iteration.story_type
        @export_configs = @story_type.export_configurations.joins(:publication)
      end

      def insert(sample)
        @raw_sample = sample
        @iteration.samples.create!(sample_params)
      end

      private

      # prepare sample to inserting
      def sample_params
        config = export_config
        time_frame = TimeFrame.find_by(frame: @raw_sample[:time_frame].downcase)
        publication = config.publication
        client = publication.client

        {
          story_type: @story_type,
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

        message = "STAGING TABLE ROW = #{@raw_sample['staging_row_id']} | "\
                  'You are trying to create a story for client/publication '\
                  'not specified in the properties section. Please check the '\
                  'method you use for getting publications or contact the manager.'
        raise ArgumentError, message
      end

      # wrap to HTML tags
      def basic_html_substitutions_body
        @raw_sample[:body].gsub!(/(?:^|\n\n|\n\t)(.+)(?:\n\n*|\n\t|$)/, '<p>\1</p>')
        @raw_sample[:body].gsub!(%r{(<svg .*?/svg>)}) { |tag| tag.gsub(%r{</?p>}, '') }
        @raw_sample[:body].gsub!(%r{(<script .*?/script>)}) { |tag| tag.gsub(%r{</?p>}, '') }

        "<html><head><title></title><style></style></head><body>#{@raw_sample[:body]}</body></html>"
      end
    end
  end
end
