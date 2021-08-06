# frozen_string_literal: true

class StoryTypeStatusesController < ApplicationController
  before_action :render_403, if: :editor?
  before_action :find_status

  def change
    @story_type.update!(status: @status, last_status_changed_at: Time.now, current_account: current_account)
  end

  private

  def find_status
    @status = Status.find(params[:status_id])
  end
end
