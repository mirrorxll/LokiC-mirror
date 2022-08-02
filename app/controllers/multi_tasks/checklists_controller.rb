# frozen_string_literal: true

module MultiTasks
  class ChecklistsController < MultiTasksController
    before_action :find_multi_task
    before_action :find_task_checklist, only: :confirm

    def new; end

    def create
      task_checklists = @multi_task.checklists
      checklists[:descriptions].each { |description| task_checklists.build(description: description).save! }
    end

    def edit; end

    def confirm
      @multi_task_checklist.update!(confirmed: params[:confirm])
    end

    private

    def find_task
      @multi_task = MultiTask.find(params[:task_id])
    end

    def find_task_checklist
      @multi_task_checklist = TaskChecklist.find(params[:id])
    end

    def checklists
      params.require(:checklists).permit(descriptions: [])
    end
  end
end
