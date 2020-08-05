# frozen_string_literal: true

class AutoFeedbackConfirmationsController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :find_auto_feedback

  def confirm
    render_400 and return if @auto_feedback_to_confirm.confirmed

    @auto_feedback_to_confirm.update(confirmed: true)
  end

  private

  def find_auto_feedback
    @confirmations = @story_type.iteration.auto_feedback_confirmations
    @auto_feedback_to_confirm = @confirmations.find(params[:id])
  end
end
