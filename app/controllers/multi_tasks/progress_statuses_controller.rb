# frozen_string_literal: true

module MultiTasks
  class ProgressStatusesController < MultiTasksController
    before_action :find_multi_task
    before_action :find_status
    before_action :find_assignment

    def change
      if @status.name.eql?('done')
        @assignment.update!(done: true, hours: params[:hours])

        unless params[:team_work].nil?
          MultiTaskTeamWork.find_or_create_by(multi_task: @multi_task)
                      .update(creator: @current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
        end
        @multi_task.update(done_at: Time.now, status: @status) if @multi_task.done_by_all_assignments?
      else
        @assignment&.update!(done: false)
        @multi_task.update(status: @status)
      end
      comment && send_notification
    end

      private

    def find_task
      @multi_task = MultiTask.find(params[:multi_task_id])
    end

    def find_status
      @status = params[:status].blank? ? Status.find(params[:status_id]) : Status.find_by(name: params[:status])
    end

    def find_assignment
      @assignment = MultiTaskAssignment.find_by(multi_task: @multi_task, account: @current_account)
    end

    def team_work_params
      params.require(:team_work)
    end

    def comment
      body, subtype = if %w[blocked archived].include? @status.name
                        ["<div><b>Status changed to #{@status.name}.</b><br>#{params[:body]}</div>", 'status comment']
                      elsif @status.name.eql?('done') && !@multi_task.done_by_all_assignments?
                        ["<b>Set status #{@status.name}.</b>", 'task comment']
                      else
                        ["<b>Status changed to #{@status.name}.</b>", 'task comment']
                      end

      @comment = @multi_task.comments.build(
        subtype: subtype,
        body: body,
        commentator: @current_account
      )
      @comment.save!
    end

    def send_notification
      accounts = (@multi_task.assignment_to.to_a << @multi_task.creator).uniq
      accounts.each do |account|
        next if account.slack.nil? || account.slack.deleted

        if @status.name.eql?('done') && !@multi_task.done_by_all_assignments?
          message = "*<#{multi_task_url(@multi_task)}| TASK ##{@multi_task.id}> | "\
                    "#{@current_account.name} set status #{@status.name}*. To change the status of task to done all executors must change the status.\n>#{@multi_task.title}"
        else
          message = "*<#{multi_task_url(@multi_task)}| TASK ##{@multi_task.id}> | "\
                    "Status changed to #{@status.name}.*\n>#{@multi_task.title}"
        end

        ::SlackNotificationJob.perform_async(account.slack.identifier, message)
        ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
      end
      MultiTasks::SlackNotifications.run(:change_status, @multi_task) unless @status.name != @multi_task.status.name
    end

    def create_team_work
      return if team_work_params[:confirm].eql?('0') || team_work_params[:sum].blank?

      team_work = MultiTaskTeamWork.find_by(multi_task: @multi_task)
      if team_work.nil?
        MultiTaskTeamWork.create!(multi_task: @multi_task, creator: @current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
      else
        team_work.update!(creator: @current_account, sum: team_work_params[:sum].to_f.round(2), hours: team_work_params[:type].eql?('hours') ? true : false)
      end
    end
    end
end
