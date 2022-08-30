# frozen_string_literal: true

namespace :multi_task do
  desc 'MultiTask reminders'
  task reminder: :environment do
    ReminderTasksJob.new.perform
  end
end
