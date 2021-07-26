# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task

  after_action  :send_notification, only: :update

  def edit; end

  def update
    @task.assignment_to.delete_all
    @task.assignment_to << Account.find(assignments_params)
  end

  def cancel; end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end

  def send_notification
    @task.assignment_to.each do |assignment|
      next if assignment.slack.nil? || assignment.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
              "ASSIGNMENT TO YOU*\n>#{@task.title}"

      SlackNotificationJob.perform_later(assignment.slack.identifier, message)
    end
  end

  def assignments_params
    params.require(:assignment_to).uniq.reject { |account| account.blank? }
  end
end
