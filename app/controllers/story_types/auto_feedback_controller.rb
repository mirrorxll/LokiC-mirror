# frozen_string_literal: true

module StoryTypes
  class AutoFeedbackController < StoryTypesController
    before_action :find_auto_feedback

    def confirm
      render_403 and return if @auto_feedback_to_confirm.confirmed

      @auto_feedback_to_confirm.update!(confirmed: true)
    end

    private

    def find_auto_feedback
      @confirmations = @iteration.auto_feedback_confirmations
      @auto_feedback_to_confirm = @confirmations.find(params[:id])
    end
  end
end
