# frozen_string_literal: true

class TaskStatusesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task
  before_action :find_status, only: :change
  after_action  :send_notification, only: :change

  def change
    @task.update!(status: @status)
    @task.update!(done_at: Time.now) if @status.name.eql?('done')
  end

  def leave_comment
    @task.status_comment&.update!(body: params[:comment]) && return

    @task.build_status_comment(subtype: 'status comment', body: params[:comment]).save!
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end

  def comment_params
    params.require(:comment)
  end

  def send_notification
    accounts = (@task.assignment_to.to_a << @task.creator).uniq
    accounts.each do |account|
      account.first_name + ' ' + account.last_name
      next if account.slack.nil? || account.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
              "STATUS CHANGED TO #{@task.status.name.upcase}*\n>#{@task.title}"

      SlackNotificationJob.perform_later(account.slack.identifier, message)
    end
  end
end
