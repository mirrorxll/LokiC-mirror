# frozen_string_literal: true

class TaskChecklistsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration
  skip_before_action :set_story_type_iteration

  before_action :find_task
  before_action :find_task_checklist, only: :confirm

  def new; end

  def create
    task_checklists = @task.checklists
    checklists[:descriptions].each { |description| task_checklists.build(description: description).save! }
  end

  def edit; end

  def confirm
    @task_checklist.update!(confirmed: params[:confirm])
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_task_checklist
    @task_checklist = TaskChecklist.find(params[:id])
  end

  def checklists
    params.require(:checklists).permit(descriptions: [])
  end
end
