# frozen_string_literal: true

class TasksConfirmsReceiptsJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform
    task_assignments = MultiTaskAssignment.where(confirmed: 0, notification_to: 0)

    task_assignments.each do |assignment|
      sleep(rand)
      account = assignment.account
      next if account.slack.nil? || account.slack.deleted

      message = "*<#{generate_task_url(assignment.task)}|Task ##{assignment.task.id}> | You need confirm receipt of task | "\
        "#{account.name}*\n" \
        "#{assignment.task.title}".gsub("\n", "\n>")
      SlackNotificationJob.new.perform(account.slack.identifier, message)
      SlackNotificationJob.new.perform('hle_lokic_task_reminders', message)
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
