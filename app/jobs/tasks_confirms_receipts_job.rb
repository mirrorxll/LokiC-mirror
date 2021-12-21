# frozen_string_literal: true

class TasksConfirmsReceiptsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        task_assignments = TaskAssignment.where(confirmed: 0)
        task_assignments.each do |assignment|
          sleep(rand)
          account = assignment.account
          next if account.slack.nil? || account.slack.deleted

          message = "*<#{generate_task_url(assignment.task)}|Task ##{assignment.task.id}> | You need confirm receipt of task | "\
            "#{account.name}*\n" \
            "#{assignment.task.title}".gsub("\n", "\n>")
          SlackNotificationJob.perform_now(account.slack.identifier, message)
          SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
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
