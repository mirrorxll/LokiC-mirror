# frozen_string_literal: true

namespace :story_type do
  namespace :staging_table do
    desc 'Attach staging table'
    task attach: :environment do
      StoryTypes::StagingTableAttachingTask.new.perform(
        ENV['story_type_id'],
        ENV['account_id'],
        ENV['table_name']
      )
    end

    desc 'Change staging table columns'
    task change_columns: :environment do
      columns = JSON.parse(ENV['columns'])

      StoryTypes::StagingTableColumnsTask.new.perform(ENV['staging_table_id'], columns)
    end

    desc 'Add staging table index'
    task add_index: :environment do
      columns = JSON.parse(ENV['columns'])

      StoryTypes::StagingTableIndexAddTask.new.perform(ENV['staging_table_id'], columns)
    end

    desc 'Drop staging table index'
    task drop_index: :environment do
      StoryTypes::StagingTableIndexDropTask.new.perform(ENV['staging_table_id'])
    end
  end
end
