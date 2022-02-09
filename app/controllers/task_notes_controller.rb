# frozen_string_literal: true

class TaskNotesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task
  before_action :find_note, only: %i[edit update cancel_edit]

  def new; end

  def create
    @note = TaskNote.new(task: @task, creator: current_account, body: note_params[:body])
    @note.save!
  end

  def edit; end

  def update
    @note.update!(body: update_note_params[:body])
  end

  def cancel_edit; end

  private

  def find_note
    @note = TaskNote.find_by(task: @task, creator: current_account)
  end

  def find_task
    @task = Task.find(params[:task_id])
  end

  def note_params
    params.require(:note).permit(:body)
  end

  def update_note_params
    params.require(:note).permit(:body)
  end
end
