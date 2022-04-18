# frozen_string_literal: true

namespace :story_type do
  namespace :reminder do
    desc 'Update reminders'
    task updates: :environment do
      StoryTypes::ReminderUpdatesJob.new.perform
    end

    desc 'Progress reminders'
    task progress: :environment do
      StoryTypes::ReminderProgressJob.new.perform
    end

    desc 'Template revision reminders'
    task template_revision: :environment do
      StoryTypes::RevisionTemplatesReminderJob.new.perform
    end
  end

  desc 'Update/Progress/Template revision reminders'
  task reminder: %w[reminder:updates reminder:progress reminder:template_revision]
end
