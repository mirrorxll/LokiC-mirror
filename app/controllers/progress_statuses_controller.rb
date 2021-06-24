# frozen_string_literal: true

class ProgressStatusesController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :find_status, only: :change
  after_action  :status_changed_to_history

  def change
    @story_type.update(status: @status, last_status_changed_at: DateTime.now)
  end

  private

  def find_status
    @status = Status.find(params[:status_id])
  end

  def status_changed_to_history
    notes = "progress status changed to '#{@status.name}'"
    record_to_change_history(@story_type, 'progress status changed', notes)
  end
end
