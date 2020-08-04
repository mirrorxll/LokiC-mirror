# frozen_string_literal: true

class EditorFeedbackController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :find_editor_feedback

  def edit; end

  def update
    if @editor_feedback.update(editor_feedback_params)
      send_notification_to_developer
      redirect_to story_type_fact_checking_doc_path(@story_type, @story_type.fact_checking_doc)
    end
  end

  private

  def find_editor_feedback
    @fcd = @story_type.fact_checking_doc
    @editor_feedback = @fcd.editor_feedback
  end

  def editor_feedback_params
    params.require(:editor_feedback).permit(:body)
  end

  def send_notification_to_developer
    target = @story_type.developer&.slack
    return if target.nil? || target.identifier.nil?

    message = "##{@story_type.id} #{@story_type.name} -- "\
              "You received the editors' feedback by #{current_account.name}. "\
              "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}|Check it>."

    SlackNotificationJob.perform_later(target.identifier, message)
  end
end
