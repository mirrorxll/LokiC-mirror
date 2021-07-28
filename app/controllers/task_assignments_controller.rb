# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task

  def edit; end

  def update
    update_assignments(@task, Account.find(assignments_params))
  end

  def cancel; end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end

  def update_assignments(task, assignments)
    old_assignments = TaskAssignment.where(task: task, account: (task.assignment_to - assignments))
    old_assignments.destroy_all unless old_assignments.empty?

    new_assignments = assignments - task.assignment_to
    task.assignment_to << new_assignments
    send_notification(new_assignments)
  end

  def send_notification(assignments)
    assignments.each do |assignment|
      next if assignment.slack.nil? || assignment.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
              "ASSIGNMENT TO YOU*\n>#{@task.title}"

      SlackNotificationJob.perform_later(assignment.slack.identifier, message)
    end
  end

  def assignments_params
    params.has_key?(:assignment_to) ? params.require(:assignment_to).uniq.reject { |account| account.blank? } : []
  end
end
