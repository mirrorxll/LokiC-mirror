# frozen_string_literal: true

class TasksController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task, only: %i[show edit update]
  before_action :grid, only: :index
  before_action :task_assignments, only: :show
  before_action :find_note, only: :show
  
  def index
    @tab_title = "LokiC :: Tasks"
    respond_to do |f|
      f.html do
        @grid.scope do |scope|
          scope.page(params[:page]).per(20)
        end
      end
    end
  end

  def show
    render_401 unless manager? || @task.access_for?(current_account)

    @comments = @task.comments.order(created_at: :desc)
    @tab_title = "LokiC :: Task ##{@task.id} <#{@task.title}>"
  end

  def new
    @task = Task.new
  end

  def create
    parent_params = task_params[:parent]
    subtasks_params = task_params[:subtasks]

    @task_parent = Task.new(parent_params.except(:assignment_to, :assistants, :notification_to, :checklists, :agencies_opportunities))
    if @task_parent.save!
      after_task_create(@task_parent, parent_params)

      unless subtasks_params.blank?
        subtasks_params.each do |subtask_params|
          subtask_params[:parent] = @task_parent
          subtask = Task.new(subtask_params.except(:assignment_to, :assistants, :checklists, :agencies_opportunities))
          after_task_create(subtask, subtask_params) if subtask.save!
        end
      end
    end
  end

  def edit; end

  def update
    @task.update!(update_task_params.except(:agencies_opportunities))

    task_checklists = @task.checklists
    update_checklists_params.each do |id, description|
      if id[0..2].eql?('new')
        task_checklists.create!(description: description)
      else
        TaskChecklist.find(id).update(description: description)
      end
    end

    update_agencies_opportunities(update_task_params[:agencies_opportunities])
  end

  def add_subtask
    @number_subtask = params[:number_subtask]
  end

  def new_subtask;
    @task_parent = Task.find(params[:parent_task])
  end

  def create_subtask
    @subtask = Task.new(subtask_params.except(:assignment_to, :notification_to, :assistants, :checklists, :agencies_opportunities))

    if @subtask.save!
      after_task_create(@subtask, subtask_params)
    end
  end

  private

  def update_agencies_opportunities(agencies_opportunities)
    ids = agencies_opportunities.to_h.map { |u_id, _row| u_id.first(2).eql?('id') ? u_id.split('_').last : next }
    old = @task.agency_opportunity_revenue_types.where.not(id: ids)
    old.each { |row| row.destroy! } unless old.blank?

    return if agencies_opportunities.blank?

    agencies_opportunities.each do |u_id, row|
      if u_id.first(2).eql?('id')
        id = u_id.split('_').last
        TaskAgencyOpportunityRevenueType.find(id)
                                        .update!(agency: MainAgency.find(row[:agency_id]),
                                                 opportunity: MainOpportunity.find(row[:opportunity_id]),
                                                 revenue_type: RevenueType.find(row[:revenue_type_id]),
                                                 percents: row[:percents])
      else
        TaskAgencyOpportunityRevenueType.create!(task: @task,
                                                 agency: MainAgency.find(row[:agency_id]),
                                                 opportunity: MainOpportunity.find(row[:opportunity_id]),
                                                 revenue_type: RevenueType.find(row[:revenue_type_id]),
                                                 percents: row[:percents])
      end
    end
  end

  def after_task_create(task, params)
    task.main_assignee = Account.find(params[:assignment_to]) unless params[:assignment_to].blank?
    task.assistants << Account.find(params[:assistants]) unless params[:assistants].blank?
    task.notification_to << Account.find(params[:notification_to]) unless params[:notification_to].blank?
    comment(task) && send_notification(task)
    task_checklists = task.checklists
    params[:checklists].each { |description| task_checklists.create!(description: description) } unless params[:checklists].blank?
    create_agencies_opportunities(task, params[:agencies_opportunities])
  end

  def create_agencies_opportunities(task, agencies_opportunities)
    task_agency_opportunity_revenue_types = task.agency_opportunity_revenue_types
    return if agencies_opportunities.blank?

    agencies_opportunities.each do |hex, age_opp|
      task_agency_opportunity_revenue_types.create!(
        agency: MainAgency.find(age_opp[:agency_id]),
        opportunity: MainOpportunity.find(age_opp[:opportunity_id]),
        revenue_type: RevenueType.find(age_opp[:revenue_type_id]),
        percents: age_opp[:percents],
      )
    end
  end

  def comment(task)
    body = "##{task.id} Task created. "
    body += if task.assignment_to.empty?
              'Not assigned.'
            else
              "Assignment to #{task.assignment_to.map(&:name).to_sentence}."
            end

    task.comments.build(
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
        manager? ? { order: :id, descending: true } : { assignment_to: current_account.id, order: :id, descending: true }
      end
    grid_params[:status] =
      if grid_params[:status].blank? && grid_params[:deleted_tasks] != 'YES'
        Status.multi_task_statuses_for_grid
      elsif grid_params[:status].length == 1
        grid_params[:status]
      end
    grid_params[:current_account] = current_account

    @grid = TasksGrid.new(grid_params.except(:collapse, :type))
  end

  def find_task
    @task = Task.find(params[:id]) || params[:task_id]
  end

  def find_note
    @note = TaskNote.find_by(task: @task, creator: current_account)
  end

  def send_notification(task)
    MultiTasks::SlackNotifications.run(:created, task)

    task.assignment_to.each do |assignment|
      next if assignment.slack.nil? || assignment.slack.deleted

      message = "*<#{task_url(task)}| TASK ##{task.id}> | "\
              "Assignment to you*\n>#{task.title}"

      ::SlackNotificationJob.perform_async(assignment.slack.identifier, message)
      ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
    end
  end

  def task_params
    result_params = {}
    parent_params = params.require(:task_parent).permit(:title, :description, :parent, :deadline, :client_id, :reminder_frequency, :access, :gather_task, :work_request, :assignment_to, :sow, :pivotal_tracker_name, :pivotal_tracker_url, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {})
    parent_params[:reminder_frequency] = parent_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(parent_params[:reminder_frequency])
    parent_params[:client] = parent_params[:client_id].blank? ? nil : ClientsReport.find(parent_params[:client_id])
    parent_params[:work_request] = parent_params[:work_request] ? WorkRequest.find(parent_params[:work_request]) : nil
    parent_params[:assistants] = parent_params[:assistants].blank? ? nil : parent_params[:assistants].uniq.reject(&:blank?).delete_if {|assignee| assignee == parent_params[:assignment_to] }
    parent_params[:notification_to] = parent_params[:notification_to].blank? ? nil : parent_params[:notification_to].uniq.reject(&:blank?).delete_if {|assignee| assignee == parent_params[:assignment_to] || (!parent_params[:assistants].blank? && parent_params[:assistants].include?(assignee)) }
    parent_params[:parent] = parent_params[:parent].blank? ? nil : Task.find(parent_params[:parent])
    parent_params[:creator] = current_account
    result_params[:parent] = parent_params

    subtasks_params = params.key?(:subtasks) ? params.require(:subtasks).each { |number, params| params.permit(:title, :description, :parent, :deadline, :client_id, :reminder_frequency, :access, :gather_task, :assignment_to, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {}) } : {}
    return result_params if subtasks_params.empty? || !parent_params[:parent].blank?

    subtasks = []
    subtasks_params.each do |number_subtask, subtask_params|
      subtask_params = subtask_params.permit(:title, :description, :parent, :deadline, :client_id, :reminder_frequency, :access, :gather_task, :assignment_to, assistants: [], checklists: [], agencies_opportunities: {})
      subtask_params[:client] = parent_params[:client]
      subtask_params[:sow] = parent_params[:sow]
      subtask_params[:pivotal_tracker_name] = parent_params[:pivotal_tracker_name]
      subtask_params[:pivotal_tracker_url] = parent_params[:pivotal_tracker_url]
      subtask_params[:reminder_frequency] = subtask_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(subtask_params[:reminder_frequency])
      subtask_params[:creator] = current_account
      subtask_params[:assistants] = subtask_params[:assistants].blank? ? nil: subtask_params[:assistants].uniq.reject(&:blank?).delete_if {|assignee| assignee == subtask_params[:assignment_to] }

      subtasks << subtask_params
    end

    result_params[:subtasks] = subtasks
    result_params
  end

  def subtask_params
    task_params = params.require(:task).permit(:title, :description, :parent, :deadline, :client_id, :reminder_frequency, :access, :gather_task, :sow, :pivotal_tracker_name, :pivotal_tracker_url, :assignment_to, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {} )
    task_params[:reminder_frequency] = task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(task_params[:reminder_frequency])
    task_params[:parent] = task_params[:parent].blank? ? nil : Task.find(task_params[:parent])
    task_params[:client] = task_params[:client_id].blank? ? nil : ClientsReport.find(task_params[:client_id])
    task_params[:creator] = current_account
    task_params[:assistants] = task_params[:assistants].blank? ? nil: task_params[:assistants].uniq.reject(&:blank?).delete_if {|assignee| assignee == task_params[:assignment_to] }
    task_params[:notification_to] = task_params[:notification_to].blank? ? nil : task_params[:notification_to].uniq.reject(&:blank?).delete_if {|assignee| assignee == task_params[:assignment_to] || (!task_params[:assistants].blank? && task_params[:assistants].include?(assignee)) }
    task_params
  end

  def assignment_to_params
    params.require(:assignment_to).uniq.reject(&:blank?)
  end

  def checklists_params
    params.key?(:checklists) ? params.require(:checklists) : []
  end

  def update_task_params
    up_task_params = params.require(:task).permit(:title, :description, :deadline, :parent, :access, :client_id, :reminder_frequency, :gather_task, :sow, :pivotal_tracker_name, :pivotal_tracker_url, agencies_opportunities: {})
    up_task_params[:reminder_frequency] = up_task_params[:reminder_frequency].blank? ? nil : TaskReminderFrequency.find(up_task_params[:reminder_frequency])
    up_task_params[:client] = up_task_params[:client_id].blank? ? nil : ClientsReport.find(up_task_params[:client_id])
    up_task_params[:parent] = up_task_params[:parent].blank? ? nil : Task.find(up_task_params[:parent])
    up_task_params
  end

  def update_checklists_params
    params.key?(:checklists) ? params.require(:checklists) : []
  end

  def comment_params
    params.require(:comment)
  end

  def task_assignments
    @task_assignments = TaskAssignment.where(task: @task)
  end
end
