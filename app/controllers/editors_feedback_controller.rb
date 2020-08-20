# frozen_string_literal: true

class EditorsFeedbackController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :find_editors_feedback
  before_action :update_editors_feedback, only: %i[update save]

  def edit; end

  def update
    send_notification_to_developer
    redirect_to story_type_fact_checking_doc_path(@story_type, @story_type.fact_checking_doc)
  end

  def save; end

  private

  def find_editors_feedback
    @fcd = @story_type.fact_checking_doc
    @editors_feedback = @fcd.editors_feedback
  end

  def update_editors_feedback
    puts editors_feedback_params
    @editors_feedback.update(editors_feedback_params)
  end

  def editors_feedback_params
    params.require(:editors_feedback).permit(:body)
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
