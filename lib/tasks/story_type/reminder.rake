# frozen_string_literal: true

namespace :story_type do
  namespace :reminder do
    desc 'Update reminders'
    task updates: :environment do
      StoryTypes::ReminderUpdatesJob.perform_now
    end

    desc 'Progress reminders'
    task progress: :environment do
      StoryTypes::ReminderProgressJob.perform_now
    end

    desc 'Template revision reminders'
    task template_revision: :environment do
      StoryTypes::RevisionTemplatesReminderJob.perform_now
    end
  end

  desc 'Update/Progress/Template revision reminders'
  task reminder: %w[reminder:updates reminder:progress reminder:template_revision]
end
