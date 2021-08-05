# frozen_string_literal: true

class TasksController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration
  before_action :find_task, only: [:show, :edit, :update]
  before_action :grid, only: [:index]
  after_action  :send_notification, only: :create
  after_action  :comment, only: :create

  def index
    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
    end
  end

  def show
    @task = Task.find(params[:id])
    @comments = @task.comments.order(created_at: :desc)
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(
      title: task_params[:title],
      description: task_params[:description],
      reminder_frequency: task_params[:reminder_frequency],
      deadline: task_params[:deadline],
      gather_task: task_params[:gather_task],
      creator: current_account
    )

    @task.assignment_to << Account.find(task_params[:assignment_to]) if @task.save!
  end

  def edit; end

  def update
    @task.update(update_task_params)
  end

  private

  def comment
    @task.comments.build(
      subtype: 'task comment',
      body: "##{@task.id} Task created. Assignment to #{@task.assignment_to.map { |assignment| assignment.name }.to_sentence}.",
      commentator: current_account
    ).save!
  end

  def grid
    grid_params =
      if params[:tasks_grid]
        params.require(:tasks_grid).permit!
      else
        !manager? ? { assignment_to: current_account.id, order: :id, descending: true } : { order: :id, descending: true }
      end
    @grid = TasksGrid.new(grid_params.except(:collapse))
  end

  def find_task
    @task = Task.find(params[:id])
  end

  def send_notification
    @task.assignment_to.each do |assignment|
      next if assignment.slack.nil? || assignment.slack.deleted

      message = "*[ LokiC ] <#{task_url(@task)}| TASK ##{@task.id}> | "\
              "ASSIGNMENT TO YOU*\n>#{@task.title}"

      SlackNotificationJob.perform_later(assignment.slack.identifier, message)
    end
  end

  def task_params
    task_params = params.require(:task).permit(:title, :description, :deadline, :reminder_frequency, :gather_task, assignment_to: [])
    task_params[:reminder_frequency] = task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(task_params[:reminder_frequency])
    task_params[:assignment_to] = task_params[:assignment_to].uniq.reject { |account| account.blank? }
    task_params
  end

  def update_task_params
    up_task_params = params.require(:task).permit(:title, :description, :deadline, :reminder_frequency, :gather_task)
    up_task_params[:reminder_frequency] = up_task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(up_task_params[:reminder_frequency])
    up_task_params
  end

  def comment_params
    params.require(:comment)
  end
end
