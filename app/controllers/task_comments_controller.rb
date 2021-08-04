# frozen_string_literal: true

class TaskCommentsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task

  def new
    @comment = Comment.new
  end

  def create
    @comment = @task.comments.build(subtype: 'task comment', body: comment_params[:body])
    @comment.commentator = current_account
    @comment.save!
  end

  def show

  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def comment_params
    params.require(:comment)
  end
end
