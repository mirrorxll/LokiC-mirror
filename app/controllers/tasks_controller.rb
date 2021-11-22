# frozen_string_literal: true

class TasksController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task, only: %i[show edit update]
  before_action :grid, only: :index
  after_action  :send_notification, only: :create

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
    render_401 if !manager? && !@task.assignment_to_or_creator?(current_account)

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
      parent: task_params[:parent],
      status: task_params[:status],
      client: task_params[:client],
      creator: current_account
    )
    @task.assignment_to << Account.find(task_params[:assignment_to]) if @task.save!
  end

  def edit; end

  def update
    @task.update!(update_task_params)
  end

  private

  def comment
    body = "##{@task.id} Task created. "
    body += if @task.assignment_to.empty?
              "Not assigned."
            else
              "Assignment to #{@task.assignment_to.map { |assignment| assignment.name }.to_sentence}."
            end
    @task.comments.build(
      subtype: 'task comment',
      body: body,
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
    grid_params[:status] = Status.multi_task_statuses_for_grid if grid_params[:deleted_tasks] != 'YES'
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
      SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
    end
  end

  def task_params
    task_params = params.require(:task).permit(:title, :description, :parent, :deadline, :status, :client_id, :reminder_frequency, :gather_task, assignment_to: [])
    task_params[:reminder_frequency] = task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(task_params[:reminder_frequency])
    task_params[:assignment_to] = task_params[:assignment_to].uniq.reject(&:blank?)
    task_params[:parent] = task_params[:parent].blank? ? nil : Task.find(task_params[:parent])
    task_params[:status] = task_params[:status].blank? ? nil : Status.find(task_params[:status])
    task_params[:client] = task_params[:client_id].blank? ? nil : ClientsReport.find(task_params[:client_id])
    task_params
  end

  def update_task_params
    up_task_params = params.require(:task).permit(:title, :description, :deadline, :parent, :status, :client_id, :reminder_frequency, :gather_task)
    up_task_params[:reminder_frequency] = up_task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(up_task_params[:reminder_frequency])
    up_task_params[:status] = up_task_params[:status].blank? ? nil : Status.find(up_task_params[:status])
    up_task_params[:client] = up_task_params[:client_id].blank? ? nil : ClientsReport.find(up_task_params[:client_id])
    up_task_params[:parent] = up_task_params[:parent].blank? ? nil : Task.find(up_task_params[:parent])
    up_task_params
  end

  def comment_params
    params.require(:comment)
  end
end
