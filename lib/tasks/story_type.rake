# frozen_string_literal: true

namespace :story_type do
  desc "Change opportunities list for story type's properties"
  task change_opportunities: :environment do
    StoryTypes::ChangeOpportunitiesTask.new.perform(ENV['story_type_id'])
  end

  desc "Set default opportunities list for story type's properties"
  task default_opportunities: :environment do
    StoryTypes::DefaultOpportunitiesTask.new.perform(ENV['story_type_id'])
  end

  desc 'Create/update export configurations for story type'
  task export_configurations: :environment do
    manual = ActiveModel::Type::Boolean.new.cast(ENV['manual'])

    StoryTypes::ExportConfigurationsTask.new.perform(
      ENV['story_type_id'],
      ENV['account_id'],
      manual
    )
  end

  desc 'Check has_updates presence'
  task check_has_updates_revise: :environment do
    StoryTypes::HasUpdatesReviseJob.new.perform
  end
end
