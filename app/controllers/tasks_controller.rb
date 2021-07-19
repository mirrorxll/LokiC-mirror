# frozen_string_literal: true

class TasksController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.create(title: tasks_params[:title],
                        description: tasks_params[:description],
                        creator: current_account,
                        status: Status.find_by(name: 'not started'))

    @task.assignment_to << Account.find(tasks_params[:assignment_to])
  end

  def edit; end

  def update

  end

  def destroy

  end

  def change_status
    @task = Task
  end

  private

  def tasks_params
    permitted = params.require(:task).permit(:title, :description, assignment_to: [])
    permitted[:assignment_to] = permitted[:assignment_to].uniq.reject { |account| account.blank? }
    permitted
  end
end
