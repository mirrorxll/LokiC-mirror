# frozen_string_literal: true

class TaskCommentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration
  skip_before_action :set_story_type_iteration
  before_action :find_task
  after_action  :send_notification, only: :create

  def new
    @comment = Comment.new
  end

  def create
    @comment = @task.comments.build(subtype: comment_params[:subtype], body: comment_params[:body])
    @comment.commentator = current_account
    @comment.save!
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :subtype)
  end

  def send_notification
    return unless @comment
    accounts = ((@task.assignment_to.to_a << @task.creator) - [@comment.commentator]).uniq
    accounts.each do |account|
      puts account.name
      next if account.slack.nil? || account.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
              "#{@comment.commentator.name} add comment | Check please*\n>#{@task.title}"

      SlackNotificationJob.perform_later(account.slack.identifier, message)
      SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
    end
  end
end
