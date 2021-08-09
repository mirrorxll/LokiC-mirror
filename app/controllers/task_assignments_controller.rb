# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task

  def edit; end

  def update
    new_assignments = new_assignments(@task, Account.find(assignments_params))
    update_assignments(@task, new_assignments)
    send_notification(new_assignments)
    comment(new_assignments)
  end

  def cancel; end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end

  def new_assignments(task, assignments)
    old_assignments = TaskAssignment.where(task: task, account: (task.assignment_to - assignments))
    old_assignments.destroy_all unless old_assignments.empty?

    assignments - task.assignment_to
  end

  def update_assignments(task, new_assignments)
    task.assignment_to << new_assignments
  end

  def comment(new_assignments)
    return if new_assignments.empty?

    @comment = @task.comments.build(
      subtype: 'task comment',
      body: "Task assignment to #{new_assignments.map { |assignment| assignment.name }.to_sentence}.",
      commentator: current_account
    )
    @comment.save!
  end

  def send_notification(assignments)
    assignments.each do |assignment|
      next if assignment.slack.nil? || assignment.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
                "ASSIGNMENT TO YOU*\n>#{@task.title}"
      SlackNotificationJob.perform_later(assignment.slack.identifier, message)
      SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
    end
  end

  def assignments_params
    params.has_key?(:assignment_to) ? params.require(:assignment_to).uniq.reject { |account| account.blank? } : []
  end
end
