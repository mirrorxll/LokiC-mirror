# frozen_string_literal: true

namespace :task do
  desc 'Task reminders'
  task reminder: :environment do
    ReminderTasksJob.new.perform
  end
end
