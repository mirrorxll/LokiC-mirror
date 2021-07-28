# frozen_string_literal: true

class ReminderTasksJob< ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        day_of_week = Date.today.strftime("%A")

        each_day = TaskReminderFrequency.find_by(name: 'each day')
        once_a_week = TaskReminderFrequency.find_by(name: 'once a week')
        two_times_a_week = TaskReminderFrequency.find_by(name: 'two times a week')
        three_times_a_week = TaskReminderFrequency.find_by(name: 'three times a week')

        dmitriy_buzina = Account.find_by(first_name: 'Dmitriy', last_name: 'Buzina')

        tasks = case day_of_week
                when 'Monday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week, once_a_week, two_times_a_week])
                when 'Tuesday'
                  Task.where(reminder_frequency: each_day)
                when 'Wednesday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week, two_times_a_week])
                when 'Thursday'
                  Task.where(reminder_frequency: each_day)
                when 'Friday'
                  Task.where(reminder_frequency: [each_day, three_times_a_week])
                when 'Saturday'
                  Task.where(reminder_frequency: each_day)
                when 'Sunday'
                  Task.where(reminder_frequency: each_day)
                else
                  raise 'Incorrect date'
                end

        tasks.each do |task|
          sleep(rand)

          next if task.assignment_to.empty? || task.status.name.in?(%w(canceled done)) || task.reminder_frequency.nil?

          task.assignment_to.each do |assignment|
            next if assignment.slack.nil? || assignment.slack.deleted

            raw_message = 'You have an unfinished task'
            raw_message += task.deadline.blank? ? "!" : " with a deadline #{task.deadline.strftime('%Y-%m-%d')}!"

            message = "*[ LokiC ] <#{generate_task_url(task)}|Task ##{task.id}> REMINDER|"\
              "| #{assignment.first_name + " " + assignment.last_name}*\n*#{raw_message}*\n" \
              "#{task.title}".gsub("\n", "\n>")
            SlackNotificationJob.perform_now(assignment.slack.identifier, message)
            SlackNotificationJob.perform_now(dmitriy_buzina.slack.identifier, message)
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
