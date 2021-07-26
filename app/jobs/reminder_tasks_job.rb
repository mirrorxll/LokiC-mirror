# frozen_string_literal: true

class ReminderTaskdJob< ApplicationJob
  queue_as :lokic

  def perform(tasks = Task.all)
    Process.wait(
      fork do
        day_of_week = Date.today.strftime("%A")
        tasks.each do |task|
          sleep(rand)

          next if task.assignment_to.empty? || task.status.name.in?(%w(canceled done)) || task.reminder_frequency.nil?

          reminder_frequency = task.reminder_frequency.name
          case reminder_frequency

          end
          each day
          once a week
          two times a week
          three times a week


          send_task_reminder(task)
        end
      end
    )
  end
end
