# frozen_string_literal: true

class TaskReceiptsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task
  before_action :find_task_assignment

  def confirm
    @task_assignment.update(confirmed: params[:confirmed], confirmed_at: Time.now)
    @task_assignments = @task.assignments
  end

  private

  def find_task_assignment
    @task_assignment = @task.current_assignment(current_account)
  end

  def find_task
    @task = Task.find(params[:task_id])
  end
end
