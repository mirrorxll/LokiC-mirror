# frozen_string_literal: true

module MultiTasks
  class ReceiptsController < MultiTasksController
    before_action :find_multi_task
    before_action :find_task_assignment

    def confirm
      @multi_task_assignment.update(confirmed: params[:confirmed], confirmed_at: Time.now)
      @multi_task_assignments = @multi_task.assignments
    end

    private

    def find_task_assignment
      @multi_task_assignment = @multi_task.current_assignment(current_account)
    end

    def find_task
      @multi_task = MultiTask.find(params[:task_id])
    end
  end
end
