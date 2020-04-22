module MiniLokiC
  module Creation
    class StagingRecords
      def self.[](table)
        client = MiniLokiC::Connect::Mysql.on(DB05,'loki_storycreator')
        stage_selection = get_stage(table, client)

        stage_selection
      end

      def self.get_stage(table, client)
        query = "select stage.*, stage.id as stage_id, stage.created_at as stage_created_at from loki_storycreator.#{table} stage
                LEFT JOIN loki_storycreator.hyperlocal_stories_v2 fkeys
                ON fkeys.stage_table = '#{table}'
                AND fkeys.stage_id = stage.id
                AND export_id = 0
                where (story_created != 1 or story_created is null) and publication_name is not null and publication_name != \"\" "

        stage_selection = client.query(query).to_a
        stage_selection
      end
    end
  end
end
