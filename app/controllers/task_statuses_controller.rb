# frozen_string_literal: true

class TaskStatusesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task
  before_action :find_status
  after_action  :send_notification, only: :change

  def change
    @task.update(status: @status)
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end

  def send_notification
    creator = @task.creator
    return if creator.slack.nil? || creator.slack.deleted

    message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
            "Status changed to #{@task.status.name}*\n>#{@task.title}"

    SlackNotificationJob.perform_later(creator.slack.identifier, message)
  end
end
