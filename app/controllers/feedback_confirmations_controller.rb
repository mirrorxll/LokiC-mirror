# frozen_string_literal: true

class FeedbackConfirmationsController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :find_feedback

  def confirm
    render_400 and return if @feedback_to_confirm.confirmed

    @feedback_to_confirm.update(confirmed: true)
  end

  private

  def find_feedback
    @confirmations = @story_type.iteration.feedback_confirmations
    @feedback_to_confirm = @confirmations.find_by(feedback_params)
  end

  def feedback_params
    params.permit(:id)
  end
end
