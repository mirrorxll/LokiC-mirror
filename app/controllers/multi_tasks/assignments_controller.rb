# frozen_string_literal: true

module MultiTasks
  class AssignmentsController < MultiTasksController
    before_action :find_multi_task

    def edit; end

    def update
      return if assistants_params.blank? && assignment_to_params.blank? && notification_to_params.blank?

      new_assignments = new_assignments(@multi_task, Account.find(assistants_params + [assignment_to_params]), notification_to_params)
      update_assignments(@multi_task, new_assignments, assignment_to_params)
      update_notification_to(@multi_task, notification_to_params)
      send_notification(new_assignments)
      comment(new_assignments)
    end

    def cancel; end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end

    def new_assignments(task, assignments, notification_to)
      old_assignments = TaskAssignment.where(multi_task: task, account: (task.assignment_to - assignments))
      old_assignments.destroy_all unless old_assignments.empty?

      old_notification = TaskAssignment.where(multi_task: task, account: (task.notification_to - notification_to), notification_to: 1)
      old_notification.destroy_all unless old_notification.empty?

      assignments - task.assignment_to
    end

    def update_assignments(task, new_assignments, new_main_assignee_id)
      task.assistants << new_assignments

      return if new_main_assignee_id.blank?

      new_main_assignee = Account.find(new_main_assignee_id)
      unless new_main_assignee == task.main_assignee
        old_main_assignee = TaskAssignment.find_by(multi_task: task, main: true)
        old_main_assignee.update(main: false) unless old_main_assignee.blank?
        TaskAssignment.find_by(multi_task: task, account: new_main_assignee).update(main: true)
      end
    end

    def update_notification_to(task, notification_to)
      task.notification_to.destroy_all && return if notification_to.empty?

      Account.find(notification_to).each do |account|
        next if TaskAssignment.find_by(multi_task: task, account: account)

        TaskAssignment.create(multi_task: task, account: account, notification_to: true)
      end
    end

    def comment(new_assignments)
      return if new_assignments.empty?

      @comment = @multi_task.comments.build(
        subtype: 'task comment',
        body: "MultiTask assignment to #{new_assignments.map(&:name).to_sentence}.",
        commentator: current_account
      )
      @comment.save!
    end

    def send_notification(assignments)
      assignments.each do |assignment|
        next if assignment.slack.nil? || assignment.slack.deleted

        message = "*<#{multi_task_url(@multi_task)}| TASK ##{@multi_task.id}> | "\
                  "Assignment to you*\n>#{@multi_task.title}"
        ::SlackNotificationJob.perform_async(assignment.slack.identifier, message)
        ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
      end
    end

    def assignment_to_params
      params[:assignment_to].present? ? params.require(:assignment_to) : nil
    end

    def assistants_params
      params[:assistants].present? ? params.require(:assistants) : []
    end

    def notification_to_params
      params[:notification_to].present? ? params.require(:notification_to) : []
    end
  end
end
