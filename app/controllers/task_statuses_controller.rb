# frozen_string_literal: true

class TaskStatusesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task
  before_action :find_status, only: :change

  def change
    if @status.name.in?(%w(blocked canceled)) && ActionController::Base.helpers.strip_tags(params[:body]).length < 5
      respond_to do |format|
        format.html { redirect_to @task }
        format.js { "$('#comment').modal('hide');" }
      end
      return
    end
    @task.update(status: @status)
    @task.update(done_at: Time.now) if @status.name.eql?('done')
    comment && send_notification
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = params[:status].blank? ? Status.find(params[:status_id]) : Status.find_by(name: params[:status])
  end

  def comment
    body, subtype = if %w(blocked canceled).include? @task.status.name
                      ["<div><b>Status changed to #{@task.status.name}.</b><br>#{params[:body]}</div>", 'status comment']
                   else
                     ["<b>Status changed to #{@task.status.name}.</b>", 'task comment']
                   end
    @comment = @task.comments.build(
      subtype: subtype,
      body: body,
      commentator: current_account
    )
    @comment.save!
  end

  def send_notification
    accounts = (@task.assignment_to.to_a << @task.creator).uniq
    accounts.each do |account|
      next if account.slack.nil? || account.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
                "Status changed to #{@task.status.name}*\n>#{@task.title}"

      SlackNotificationJob.perform_later(account.slack.identifier, message)
    end
  end
end
