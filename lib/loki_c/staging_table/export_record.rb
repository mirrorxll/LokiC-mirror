# frozen_string_literal: true

module LokiC
  module Queries
    class ExportRecord # :nodoc:
      def initializer(story, hash_to_export)
        @export = transform(story, hash_to_export)
      end

      def insert_and_update
        client = Mysql2.new('jdbc:mysql://localhost:3306/LokiC_development', 'LokiC_development')
        client.query(insert_query)
        client.query(update_query)
        client.close
      end

      private

      def transform(story, hash)
        hash.transform_keys!(&:to_sym)
        {
          table_name: story.staging_table.name,
          iteration: story.story_iterations.last[:number],
          staging_id: hash[:id],
          headline: hash[:headline],
          teaser: hash[:teaser],
          output: wrap_to_p_tags(hash[:output])
        }
      end

      def wrap_to_p_tags(output)
        output.gsub(/(?:^|\n\n|\n\t)(.+)(?:\n\n*|\n\t|$)/, '<p>\1</p>')
      end

      # insert to export table
      def insert_query
        %|insert into story_types_to_export (
            headline,
            teaser,
            output,
            iteration,
            staging_table,
            staging_id,
          ) values (
            #{@export[:headline].dump},
            #{@export[:teaser].dump},
            #{@export[:output].dump},
            #{@export[:iteration].dump},
            #{@export[:staging_table].dump},
            #{@export[:staging_id]});|
      end

      # update staging record
      def update_query
        %(update `#{@export[:staging_table]}` set story_created = 1;)
      end
    end
  end
end
