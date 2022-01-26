# frozen_string_literal: true

module MiniLokiC
  module Creation
    # insert created stories to stories table
    class Samples
      def initialize(staging_table, options)
        @staging_table = staging_table
        @sampled = options[:sampled]
        @iteration = options[:iteration]
        @story_type = @iteration.story_type
        @export_configs = @story_type.export_configurations.joins(:publication)
      end

      def insert(sample)
        raise ArgumentError, "time_frame can't be blank!" unless sample[:time_frame].present?
        raise ArgumentError, "staging_row_id can't be blank!" unless sample[:staging_row_id].present?
        raise ArgumentError, "organization_ids can't be blank!" unless sample[:organization_ids].present?

        @raw_sample = sample
        Story.create!(sample_params)
      end

      private

      # prepare sample to inserting
      def sample_params
        config = export_config
        time_frame = TimeFrame.find_or_create_by!(frame: @raw_sample[:time_frame].downcase)
        publication = config.publication
        client = publication.client

        {
          story_type: @story_type,
          iteration: @iteration,
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

        message =
          "LokiC has blocked story creation for staging table row ID = #{@raw_sample[:staging_row_id]}\n"\
          "Reasons why you see this message:\n"\
          "1. You are trying to create a story for client/publication not specified in the properties section.\n"\
          "2. You didn't press [ create/update ] export configurations button.\n"\
          "Please check these or contact with the manager\n---\n"

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
