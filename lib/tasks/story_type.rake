# frozen_string_literal: true

namespace :story_type do
  desc 'Sync PL clients, publications, tags, sections with LokiC'
  task clients_pubs_tags_sections: :environment do
    StoryTypes::ClientsPubsTagsSectionsJob.new.perform
  end

  desc 'Sync PL photo buckets with LokiC'
  task photo_buckets: :environment do
    StoryTypes::PhotoBucketsJob.new.perform
  end

  desc 'Sync PL opportunities with LokiC'
  task opportunities: :environment do
    StoryTypes::OpportunitiesJob.new.perform
  end

  desc 'Check has_updates presence'
  task check_has_updates_revise: :environment do
    StoryTypes::HasUpdatesReviseJob.new.perform
  end

  desc 'Create and execute iteration'
  task :execute, [:story_type_id] => :environment do |_t, args|
    StoryTypes::CronTabJob.new.perform(args.story_type_id)
  end
end
