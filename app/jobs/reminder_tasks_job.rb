# frozen_string_literal: true

class ReminderTasksJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        day_of_week = Date.today.strftime("%A")

        each_day = TaskReminderFrequency.find_by(name: 'each day')
        once_a_week = TaskReminderFrequency.find_by(name: 'once a week')
        two_times_a_week = TaskReminderFrequency.find_by(name: 'two times a week')
        three_times_a_week = TaskReminderFrequency.find_by(name: 'three times a week')
        monday = TaskReminderFrequency.find_by(name: 'each Monday')
        tuesday = TaskReminderFrequency.find_by(name: 'each Tuesday')
        wednesday = TaskReminderFrequency.find_by(name: 'each Wednesday')
        thursday = TaskReminderFrequency.find_by(name: 'each Thursday')
        friday = TaskReminderFrequency.find_by(name: 'each Friday')
        saturday = TaskReminderFrequency.find_by(name: 'each Saturday')
        sunday = TaskReminderFrequency.find_by(name: 'each Sunday')

        tasks = case day_of_week
                when 'Monday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week, once_a_week, two_times_a_week, monday])
                when 'Tuesday'
                  Task.where(reminder_frequency: [each_day, tuesday])
                when 'Wednesday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week, two_times_a_week, wednesday])
                when 'Thursday'
                  Task.where(reminder_frequency: [each_day, thursday])
                when 'Friday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week, friday])
                when 'Saturday'
                  Task.where(reminder_frequency: [each_day, saturday])
                when 'Sunday'
                  Task.where(reminder_frequency: [each_day, sunday])
                else
                  raise 'Incorrect date'
                end

        tasks.each do |task|
          sleep(rand)

          next if task.assignment_to.empty? || task.status.name.in?(%w(canceled done deleted)) || task.reminder_frequency.nil?

          task.assignment_to.each do |assignment|
            next if assignment.slack.nil? || assignment.slack.deleted

            message = "*Unfinished <#{generate_task_url(task)}|Task ##{task.id}> | REMINDER | "\
              "#{assignment.name}*\n" \
              "#{task.title}".gsub("\n", "\n>")
            SlackNotificationJob.perform_now(assignment.slack.identifier, message)
            SlackNotificationJob.perform_now('hle_lokic_task_reminders', message)
          end
        end

        tasks_with_deadlines = Task.where.not(deadline: nil)
        tasks_with_deadlines.each do |task|
          sleep(rand)
          next if task.status.name.in?(%w(canceled done deleted))

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

            message = "*#{deadline_message} | <#{generate_task_url(task)}|Task ##{task.id}> | "\
                    "#{account.name}*\n" \
                    "#{task.title}".gsub("\n", "\n>")
            SlackNotificationJob.perform_now(account.slack.identifier, message)
            SlackNotificationJob.perform_now('hle_lokic_task_reminders', message)
          end
        end
      end
    )
  end

  private

  def generate_task_url(task)
    host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
    "#{host}#{Rails.application.routes.url_helpers.task_path(task)}"
  end
end
