# frozen_string_literal: true

module MultiTasks
  module SlackNotifications
    module_function

    def run(type, task)
      parent = task.parent
      notification_to = parent.nil? ? task.notification_to : (parent.notification_to + task.notification_to).uniq

      notification_to.each do |account|
        next if account.slack.nil? || account.slack.deleted

        message =
          if type.eql?(:created) && !parent
            Messages.created(task, account.name)
          elsif type.eql?(:created) && parent
            Messages.subtask_created(task, account.name)
          elsif type.eql?(:change_status) && !parent
            Messages.changed_status(task, account.name)
          elsif type.eql?(:change_status) && parent
            Messages.subtask_changed_status(task, account.name)
          end

        SlackNotificationJob.new.perform(account.slack.identifier, message)
        SlackNotificationJob.new.perform('hle_lokic_task_reminders', message)
      end
    end
  end
end