# frozen_string_literal: true

namespace :task do
  desc 'Task reminders'
  task reminder: :environment do
    ReminderTasksJob.perform_now
  end
end
