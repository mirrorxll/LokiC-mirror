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
      @assignment.update!(done: true)
      @task.update(done_at: Time.now, status: @status) if @task.done_by_all_assignments?
    else
      @assignment.update!(done: false)
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

  def comment
    body, subtype = if %w(blocked canceled).include? @status.name
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
                  "#{current_account.name} set status #{@status.name}*. To change the status of a task to done all performers must change the status.\n>#{@task.title}"
      else
        message = "*<#{task_url(@task)}| TASK ##{@task.id}> | "\
                  "Status changed to #{@status.name}.*\n>#{@task.title}"
      end

      SlackNotificationJob.perform_later(account.slack.identifier, message)
      SlackNotificationJob.perform_later(Rails.env.production? ? 'hle_lokic_task_reminders' : 'hle_lokic_development_messages', message)
    end
  end
end
