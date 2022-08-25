# frozen_string_literal: true

class ReminderTasksJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(*_args)
    day_of_week = Date.today.strftime('%A')

    each_day = MultiTaskReminderFrequency.find_by(name: 'each day')
    once_a_week = MultiTaskReminderFrequency.find_by(name: 'once a week')
    two_times_a_week = MultiTaskReminderFrequency.find_by(name: 'two times a week')
    three_times_a_week = MultiTaskReminderFrequency.find_by(name: 'three times a week')
    monday = MultiTaskReminderFrequency.find_by(name: 'each Monday')
    tuesday = MultiTaskReminderFrequency.find_by(name: 'each Tuesday')
    wednesday = MultiTaskReminderFrequency.find_by(name: 'each Wednesday')
    thursday = MultiTaskReminderFrequency.find_by(name: 'each Thursday')
    friday = MultiTaskReminderFrequency.find_by(name: 'each Friday')
    saturday = MultiTaskReminderFrequency.find_by(name: 'each Saturday')
    sunday = MultiTaskReminderFrequency.find_by(name: 'each Sunday')

    tasks = case day_of_week
            when 'Monday'
              MultiTask.where(reminder_frequency: [each_day, three_times_a_week, once_a_week, two_times_a_week, monday])
            when 'Tuesday'
              MultiTask.where(reminder_frequency: [each_day, tuesday])
            when 'Wednesday'
              MultiTask.where(reminder_frequency: [each_day, three_times_a_week, two_times_a_week, wednesday])
            when 'Thursday'
              MultiTask.where(reminder_frequency: [each_day, thursday])
            when 'Friday'
              MultiTask.where(reminder_frequency: [each_day, three_times_a_week, friday])
            when 'Saturday'
              MultiTask.where(reminder_frequency: [each_day, saturday])
            when 'Sunday'
              MultiTask.where(reminder_frequency: [each_day, sunday])
            else
              raise 'Incorrect date'
            end

    tasks.each do |task|
      sleep(rand)
      if task.assignment_to.empty? || task.status.name.in?(%w[blocked canceled done deleted]) || task.reminder_frequency.nil?
        next
      end

      task.assignment_to.each do |assignment|
        next if assignment.slack.nil? || assignment.slack.deleted

        sleep(rand)

        message = "*[ LokiC ] Unfinished <#{generate_task_url(task)} | Task ##{task.id}> | REMINDER | "\
          "#{assignment.name}*\n" \
          "#{task.title}".gsub("\n", "\n>")
        SlackNotificationJob.new.perform(assignment.slack.identifier, message)
        SlackNotificationJob.new.perform('hle_lokic_task_reminders', message)
      end
    end

    tasks_with_deadlines = Task.where.not(deadline: nil)
    tasks_with_deadlines.each do |task|
      sleep(rand)
      next if task.status.name.in?(%w[blocked canceled done deleted])

      deadline = task.deadline
      deadline_message = if deadline - 5.days == Date.today
                           'Deadline after 5 days'
                         elsif deadline - 1.days == Date.today
                           'Deadline tomorrow'
                         elsif deadline == Date.today
                           'Deadline today'
                         elsif deadline < Date.today
                           'Deadline passed'
                         else
                           next
                         end

      accounts = (task.assignment_to.to_a << task.creator).uniq
      accounts.each do |account|
        next if account.slack.nil? || account.slack.deleted

        sleep(rand)
        message = "*[ LokiC ] #{deadline_message} | <#{generate_task_url(task)}|Task ##{task.id}> | "\
                "#{account.name}*\n" \
                "#{task.title}".gsub("\n", "\n>")
        SlackNotificationJob.new.perform(account.slack.identifier, message)
        SlackNotificationJob.new.perform('hle_lokic_task_reminders', message)
      end
    end
  end

  private

  def generate_task_url(task)
    host =
      case Rails.env
      when 'production'
        'https://lokic.locallabs.com'
      when 'staging'
        'https://lokic-staging.locallabs.com'
      else
        'http://localhost:3000'
      end

    "#{host}#{Rails.application.routes.url_helpers.multi_task_path(task)}"
  end
end
