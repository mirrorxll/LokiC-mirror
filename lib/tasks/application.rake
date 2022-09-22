# frozen_string_literal: true

desc 'Sync Slack accounts with LokiC'
task slack_accounts: :environment do
  SlackAccountsJob.new.perform
end

desc 'Sync PL clients, publications, tags, sections with LokiC'
task clients_pubs_tags_sections: :environment do
  ClientsPubsTagsSectionsTask.new.perform
end

desc 'Sync PL photo buckets with LokiC'
task photo_buckets: :environment do
  PhotoBucketsTask.new.perform
end

desc 'Sync PL opportunities with LokiC'
task opportunities: :environment do
  OpportunitiesTask.new.perform
end

desc 'Sync schemas-tables with LokiC'
task schemas_tables: :environment do
  SchemasTablesTask.new.perform
end
