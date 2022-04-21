# frozen_string_literal: true

class TasksConfirmsReceiptsJob < ApplicationJob
  queue_as :lokic

  def perform
    task_assignments = TaskAssignment.where(confirmed: 0, notification_to: 0)
    task_assignments.each do |assignment|
      sleep(rand)
      account = assignment.account
      next if account.slack.nil? || account.slack.deleted

      message = "*<#{generate_task_url(assignment.task)}|Task ##{assignment.task.id}> | You need confirm receipt of task | "\
        "#{account.name}*\n" \
        "#{assignment.task.title}".gsub("\n", "\n>")
      SlackNotificationJob.perform_now(account.slack.identifier, message)
      SlackNotificationJob.perform_later('hle_lokic_task_reminders', message)
    end
  end

  private

  def generate_task_url(task)
    host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
    "#{host}#{Rails.application.routes.url_helpers.task_path(task)}"
  end
end
