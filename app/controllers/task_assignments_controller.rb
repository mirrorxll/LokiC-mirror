# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task

  def edit; end

  def update
    return if assistants_params.blank? && assignment_to_params.blank?

    new_assignments = new_assignments(@task, Account.find(assistants_params + [assignment_to_params]))
    update_assignments(@task, new_assignments, assignment_to_params)
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

  def update_assignments(task, new_assignments, new_main_assignee_id)
    task.assistants << new_assignments

    return if new_main_assignee_id.blank?
    new_main_assignee = Account.find(new_main_assignee_id)
    unless new_main_assignee == task.main_assignee
      old_main_assignee = TaskAssignment.find_by(task: task, main: true)
      old_main_assignee.update(main: false) unless old_main_assignee.blank?
      TaskAssignment.find_by(task: task, account: new_main_assignee).update(main: true)
    end
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

      message = "*<#{task_url(@task)}| TASK ##{@task.id}> | "\
                "Assignment to you*\n>#{@task.title}"
      SlackNotificationJob.perform_later(assignment.slack.identifier, message)
      SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
    end
  end

  def assignment_to_params
    params[:assignment_to].present? ? params.require(:assignment_to) : nil
  end

  def assistants_params
    params[:assistants].present? ? params.require(:assistants) : []
  end
end
