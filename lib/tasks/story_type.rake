# frozen_string_literal: true

namespace :story_type do
  desc 'Sync PL clients, publications, tags, sections with LokiC'
  task clients_pubs_tags_sections: :environment do
    StoryTypes::ClientsPubsTagsSectionsJob.perform_now
  end

  desc 'Sync PL photo buckets with LokiC'
  task photo_buckets: :environment do
    StoryTypes::PhotoBucketsJob.perform_now
  end

  desc 'Sync PL opportunities with LokiC'
  task opportunities: :environment do
    StoryTypes::OpportunitiesJob.perform_now
  end

  desc 'Check has_updates presence'
  task check_has_updates_revise: :environment do
    StoryTypes::HasUpdatesReviseJob.perform_now
  end

  desc 'Create and execute iteration'
  task :execute, [:story_type_id] => :environment do |_t, args|
    StoryTypes::CronTabJob.perform_now(args.story_type_id)
  end
end
