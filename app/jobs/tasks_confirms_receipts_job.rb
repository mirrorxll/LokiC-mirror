# frozen_string_literal: true

class TasksConfirmsReceiptsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        task_receipts = TaskReceipt.where(confirmed: 0)
        task_receipts.each do |receipt|
          next if receipt.assignment.slack.nil? || receipt.assignment.slack.deleted

          message = "*[ LokiC ] <#{generate_task_url(receipt.task)}|Task ##{receipt.task.id}> | You need confirm receipt | "\
            "#{receipt.assignment.name}*\n" \
            "#{receipt.task.title}".gsub("\n", "\n>")
          SlackNotificationJob.perform_now(receipt.assignment.slack.identifier, message)
          SlackNotificationJob.perform_now('hle_lokic_task_reminders', message)
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
