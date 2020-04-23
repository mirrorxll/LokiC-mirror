require_relative '../functions/functions'

module MiniLokiC
  module Creation
    class Story
      def initialize(stage_table, stage_id, export, output)
        client = MiniLokiC::Connect::Mysql.on(DB05,'loki_storycreator')
        output = output.gsub(/[ \t]{2,}/, ' ')

        body = basic_html_substitutions_body(output.escaped)
        story = construct(body)

        export['stage_table'] = stage_table
        export['stage_id'] = stage_id
        export['output'] = story
        export['updated_at'] = Time.now.to_s

        story_rules = insert_rules(export.escaped)

        client.query("insert into loki_storycreator.hyperlocal_stories_v2#{story_rules}")

        client.query("update loki_storycreator.#{stage_table} set story_created = 1 where id = #{stage_id}")
      end

      def basic_html_substitutions_body(string)
        string = string.gsub(/(?:^|\n\n|\n\t)(.{1,})(?:\n\n*|\n\t|$)/, '<p>\1</p>')
        string
      end

      def construct(body)
        "<html><head><title></title><style></style></head><body>" + body + '</body></html>'
      end
    end
  end
end

