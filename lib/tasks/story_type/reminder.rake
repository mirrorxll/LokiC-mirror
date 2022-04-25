# frozen_string_literal: true

namespace :story_type do
  namespace :reminder do
    desc 'Update reminders'
    task updates: :environment do
      StoryTypes::ReminderUpdatesTask.new.perform
    end

    desc 'Progress reminders'
    task progress: :environment do
      StoryTypes::ReminderProgressTask.new.perform
    end

    desc 'Template revision reminders'
    task template_revision: :environment do
      StoryTypes::RevisionTemplatesReminderTask.new.perform
    end
  end

  desc 'Update/Progress/Template revision reminders'
  task reminder: %w[reminder:template_revision reminder:updates reminder:progress]
end
