# frozen_string_literal: true

class TaskStatusesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task
  before_action :find_status
  before_action :find_assignment

  def change
    if @status.name.eql?('done')
      @assignment.update!(done: true, hours: params[:hours])

      unless params[:team_work].nil?
        TaskTeamWork.find_or_create_by(task: @task)
                    .update(creator: current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
      end
      @task.update(done_at: Time.now, status: @status) if @task.done_by_all_assignments?
    else
      @assignment&.update!(done: false)
      @task.update(status: @status)
    end
    comment && send_notification
  end

  private

  def find_task
    @task = Task.find(params[:task_id])
  end

  def find_status
    @status = params[:status].blank? ? Status.find(params[:status_id]) : Status.find_by(name: params[:status])
  end

  def find_assignment
    @assignment = TaskAssignment.find_by(task: @task, account: current_account)
  end

  def team_work_params
    params.require(:team_work)
  end

  def comment
    body, subtype = if %w[blocked canceled].include? @status.name
                      ["<div><b>Status changed to #{@status.name}.</b><br>#{params[:body]}</div>", 'status comment']
                    elsif @status.name.eql?('done') && !@task.done_by_all_assignments?
                      ["<b>Set status #{@status.name}.</b>", 'task comment']
                    else
                      ["<b>Status changed to #{@status.name}.</b>", 'task comment']
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

      if @status.name.eql?('done') && !@task.done_by_all_assignments?
        message = "*<#{task_url(@task)}| TASK ##{@task.id}> | "\
                  "#{current_account.name} set status #{@status.name}*. To change the status of task to done all executors must change the status.\n>#{@task.title}"
      else
        message = "*<#{task_url(@task)}| TASK ##{@task.id}> | "\
                  "Status changed to #{@status.name}.*\n>#{@task.title}"
      end

      ::SlackNotificationJob.perform_async(account.slack.identifier, message)
      ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
    end
  end

  def create_team_work
    return if team_work_params[:confirm].eql?('0') || team_work_params[:sum].blank?

    team_work = TaskTeamWork.find_by(task: @task)
    if team_work.nil?
      TaskTeamWork.create!(task: @task, creator: current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
    else
      team_work.update!(creator: current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
    end
  end
end
