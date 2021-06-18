# frozen_string_literal: true

class ProgressStatusesController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :find_status, only: :change

  def change
    @story_type.update(status: @status)
  end

  private

  def find_status
    @status = Status.find(params[:status_id])
  end
end
