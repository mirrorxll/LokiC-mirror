# frozen_string_literal: true

module MultiTasks
  class MainController < MultiTasksController
    before_action :find_multi_task, only: %i[show edit update]

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    before_action :access_to_show, only: :show
    before_action :multi_task_assignments, only: :show
    before_action :find_note, only: :show

    def index
      @tab_title = 'LokiC :: MultiTasks'
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def show
      @comments = @multi_task.comments.order(created_at: :desc)
      @tab_title = "LokiC :: MultiTask ##{@multi_task.id} <#{@multi_task.title}>"
    end

    def new
      @multi_task = MultiTask.new
    end

    def create
      parent_params = task_params[:parent]
      subtasks_params = task_params[:subtasks]

      @multi_task_parent = MultiTask.new(parent_params.except(:assignment_to, :assistants, :notification_to,
                                                              :checklists, :agencies_opportunities))
      if @multi_task_parent.save!
        after_task_create(@multi_task_parent, parent_params)

        unless subtasks_params.blank?
          subtasks_params.each do |subtask_params|
            subtask_params[:parent] = @multi_task_parent
            subtask = MultiTask.new(subtask_params.except(:assignment_to, :assistants, :checklists,
                                                          :agencies_opportunities))
            after_task_create(subtask, subtask_params) if subtask.save!
          end
        end
      end
    end

    def edit; end

    def update
      @multi_task.update!(update_task_params.except(:agencies_opportunities))

      task_checklists = @multi_task.checklists
      update_checklists_params.each do |id, description|
        if id[0..2].eql?('new')
          task_checklists.create!(description: description)
        else
          MultiTaskChecklist.find(id).update(description: description)
        end
      end

      update_agencies_opportunities(update_task_params[:agencies_opportunities])
    end

    def add_subtask
      @number_subtask = params[:number_subtask]
    end

    def new_subtask
      @multi_task_parent = MultiTask.find(params[:parent_task])
    end

    def create_subtask
      @subtask = MultiTask.new(subtask_params.except(:assignment_to, :notification_to, :assistants, :checklists,
                                                     :agencies_opportunities))

      after_task_create(@subtask, subtask_params) if @subtask.save!
    end

    private

    def grid_lists
      statuses = Status.multi_task_statuses(created: true)
      @lists = HashWithIndifferentAccess.new

      @lists['assigned'] = { 'multi_task_assignments.account_id': current_account.id, status: statuses } if @multi_tasks_permissions['grid']['assigned']
      @lists['created'] = { creator: current_account, status: statuses } if @multi_tasks_permissions['grid']['created']
      @lists['all'] = { status: statuses } if @multi_tasks_permissions['grid']['all']
      @lists['archived'] = { status: Status.find_by(name: 'archived') } if @multi_tasks_permissions['grid']['archived']
    end

    def current_list
      keys = @lists.keys
      @current_list =
        if keys.include?(params[:list])
          params[:list]
        else
          (current_account.manager? || current_account.multi_tasks_manager?) && @lists['all'] ? 'all' : keys.first
        end
    end

    def generate_grid
      return unless @current_list

      @grid = MultiTasksGrid.new(params[:multi_tasks_grid]) do |scope|
        scope.where(@lists[@current_list])
      end
      @grid.current_account = current_account
    end

    def access_to_show
      return if @multi_task.access_for?(current_account)

      status_deleted = Status.find_by(name: 'archived')

      if @lists['assigned'] && @multi_task.assignment_to.include?(current_account) && @multi_task.status != status_deleted
        return
      end
      return if @lists['created'] && @multi_task.creator.eql?(current_account) && @multi_task.status != status_deleted
      return if @lists['all'] && @multi_task.status != status_deleted
      return if @lists['archived'] && @multi_task.status.eql?(status_deleted)

      flash[:error] = { multi_task: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def update_agencies_opportunities(agencies_opportunities)
      ids = agencies_opportunities.to_h.map { |u_id, _row| u_id.first(2).eql?('id') ? u_id.split('_').last : next }
      old = @multi_task.agency_opportunity_revenue_types.where.not(id: ids)
      old.each(&:destroy!) unless old.blank?

      return if agencies_opportunities.blank?

      agencies_opportunities.each do |u_id, row|
        if u_id.first(2).eql?('id')
          id = u_id.split('_').last
          MultiTaskAgencyOpportunityRevenueType.find(id)
                                               .update!(agency: MainAgency.find(row[:agency_id]),
                                                        opportunity: MainOpportunity.find(row[:opportunity_id]),
                                                        revenue_type: RevenueType.find(row[:revenue_type_id]),
                                                        percents: row[:percents])
        else
          MultiTaskAgencyOpportunityRevenueType.create!(multi_task: @multi_task,
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
      unless params[:checklists].blank?
        params[:checklists].each { |description| task_checklists.create!(description: description) }
      end
      create_agencies_opportunities(task, params[:agencies_opportunities])
    end

    def create_agencies_opportunities(task, agencies_opportunities)
      task_agency_opportunity_revenue_types = task.agency_opportunity_revenue_types
      return if agencies_opportunities.blank?

      agencies_opportunities.each do |_hex, age_opp|
        task_agency_opportunity_revenue_types.create!(
          agency: MainAgency.find(age_opp[:agency_id]),
          opportunity: MainOpportunity.find(age_opp[:opportunity_id]),
          revenue_type: RevenueType.find(age_opp[:revenue_type_id]),
          percents: age_opp[:percents]
        )
      end
    end

    def comment(task)
      body = "##{task.id} MultiTask created. "
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

    def find_note
      @note = MultiTaskNote.find_by(multi_task: @multi_task, creator: current_account)
    end

    def send_notification(task)
      MultiTasks::SlackNotifications.run(:created, task)

      task.assignment_to.each do |assignment|
        next if assignment.slack.nil? || assignment.slack.deleted

        message = "*<#{multi_task_url(task)}| TASK ##{task.id}> | "\
              "Assignment to you*\n>#{task.title}"

        ::SlackNotificationJob.perform_async(assignment.slack.identifier, message)
        ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
      end
    end

    def task_params
      result_params = {}
      parent_params = params.require(:multi_task_parent).permit(:title, :description, :parent, :deadline, :client_id,
                                                                :reminder_frequency, :access, :gather_task, :work_request, :assignment_to, :sow, :pivotal_tracker_name, :pivotal_tracker_url, :priority, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {})
      parent_params[:reminder_frequency] =
        parent_params[:reminder_frequency].blank? ? nil : MultiTaskReminderFrequency.find(parent_params[:reminder_frequency])
      parent_params[:client] = parent_params[:client_id].blank? ? nil : ClientsReport.find(parent_params[:client_id])
      parent_params[:work_request] = parent_params[:work_request] ? WorkRequest.find(parent_params[:work_request]) : nil
      parent_params[:assistants] = if parent_params[:assistants].blank?
                                     nil
                                   else
                                     parent_params[:assistants].uniq.reject(&:blank?).delete_if do |assignee|
                                       assignee == parent_params[:assignment_to]
                                     end
                                   end
      parent_params[:notification_to] = if parent_params[:notification_to].blank?
                                          nil
                                        else
                                          parent_params[:notification_to].uniq.reject(&:blank?).delete_if do |assignee|
                                            assignee == parent_params[:assignment_to] || (!parent_params[:assistants].blank? && parent_params[:assistants].include?(assignee))
                                          end
                                        end
      parent_params[:parent] = parent_params[:parent].blank? ? nil : MultiTask.find(parent_params[:parent])
      parent_params[:creator] = current_account
      result_params[:parent] = parent_params

      subtasks_params = if params.key?(:subtasks)
                          params.require(:subtasks).each do |_number, params|
                            params.permit(:title, :description, :parent, :deadline, :client_id, :reminder_frequency, :access, :gather_task, :priority,
                                          :assignment_to, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {})
                          end
                        else
                          {}
                        end
      return result_params if subtasks_params.empty? || !parent_params[:parent].blank?

      subtasks = []
      subtasks_params.each do |_number_subtask, subtask_params|
        subtask_params = subtask_params.permit(:title, :description, :parent, :deadline, :client_id,
                                               :reminder_frequency, :access, :gather_task, :priority, :assignment_to, assistants: [], checklists: [], agencies_opportunities: {})
        subtask_params[:client] = parent_params[:client]
        subtask_params[:sow] = parent_params[:sow]
        subtask_params[:pivotal_tracker_name] = parent_params[:pivotal_tracker_name]
        subtask_params[:pivotal_tracker_url] = parent_params[:pivotal_tracker_url]
        subtask_params[:reminder_frequency] =
          subtask_params[:reminder_frequency].blank? ? nil : MultiTaskReminderFrequency.find(subtask_params[:reminder_frequency])
        subtask_params[:creator] = current_account
        subtask_params[:assistants] = if subtask_params[:assistants].blank?
                                        nil
                                      else
                                        subtask_params[:assistants].uniq.reject(&:blank?).delete_if do |assignee|
                                          assignee == subtask_params[:assignment_to]
                                        end
                                      end

        subtasks << subtask_params
      end

      result_params[:subtasks] = subtasks
      result_params
    end

    def subtask_params
      task_params = params.require(:multi_task).permit(:title, :description, :parent, :deadline, :client_id,
                                                       :reminder_frequency, :access, :gather_task, :sow, :pivotal_tracker_name, :pivotal_tracker_url, :priority, :assignment_to, assistants: [], notification_to: [], checklists: [], agencies_opportunities: {})
      task_params[:reminder_frequency] =
        task_params[:reminder_frequency].blank? ? nil : MultiTaskReminderFrequency.find(task_params[:reminder_frequency])
      task_params[:parent] = task_params[:parent].blank? ? nil : MultiTask.find(task_params[:parent])
      task_params[:client] = task_params[:client_id].blank? ? nil : ClientsReport.find(task_params[:client_id])
      task_params[:creator] = current_account
      task_params[:assistants] = if task_params[:assistants].blank?
                                   nil
                                 else
                                   task_params[:assistants].uniq.reject(&:blank?).delete_if do |assignee|
                                     assignee == task_params[:assignment_to]
                                   end
                                 end
      task_params[:notification_to] = if task_params[:notification_to].blank?
                                        nil
                                      else
                                        task_params[:notification_to].uniq.reject(&:blank?).delete_if do |assignee|
                                          assignee == task_params[:assignment_to] || (!task_params[:assistants].blank? && task_params[:assistants].include?(assignee))
                                        end
                                      end
      task_params
    end

    def assignment_to_params
      params.require(:assignment_to).uniq.reject(&:blank?)
    end

    def checklists_params
      params.key?(:checklists) ? params.require(:checklists) : []
    end

    def update_task_params
      up_task_params = params.require(:multi_task).permit(:title, :description, :deadline, :parent, :access,
                                                          :client_id, :reminder_frequency, :gather_task, :sow, :pivotal_tracker_name, :pivotal_tracker_url, :priority, agencies_opportunities: {})
      up_task_params[:reminder_frequency] =
        up_task_params[:reminder_frequency].blank? ? nil : MultiTaskReminderFrequency.find(up_task_params[:reminder_frequency])
      up_task_params[:client] = up_task_params[:client_id].blank? ? nil : ClientsReport.find(up_task_params[:client_id])
      up_task_params[:parent] = up_task_params[:parent].blank? ? nil : MultiTask.find(up_task_params[:parent])
      up_task_params
    end

    def update_checklists_params
      params.key?(:checklists) ? params.require(:checklists) : []
    end

    def comment_params
      params.require(:comment)
    end

    def multi_task_assignments
      @multi_task_assignments = MultiTaskAssignment.where(multi_task: @multi_task)
    end
  end
end
