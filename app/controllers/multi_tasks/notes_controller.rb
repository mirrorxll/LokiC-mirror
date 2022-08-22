# frozen_string_literal: true

module MultiTasks
  class NotesController < MultiTasksController
    before_action :find_multi_task
    before_action :find_note, only: %i[edit update cancel_edit]

    def new; end

    def create
      @note = TaskNote.new(multi_task: @multi_task, creator: current_account, body: note_params[:body])
      @note.save!
    end

    def edit; end

    def update
      @note.update!(body: update_note_params[:body])
    end

    def cancel_edit; end

    private

    def find_note
      @note = TaskNote.find_by(multi_task: @multi_task, creator: current_account)
    end

    def find_task
      @multi_task = MultiTask.find(params[:task_id])
    end

    def note_params
      params.require(:note).permit(:body)
    end

    def update_note_params
      params.require(:note).permit(:body)
    end
  end
end
