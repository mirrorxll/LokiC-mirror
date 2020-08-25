# frozen_string_literal: true

class ReviewersFeedbackController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :find_fcd_feedback

  def new; end

  def create
    @reviewers_feedback = @fcd.reviewers_feedback.build(reviewers_feedback_params)
    @reviewers_feedback.reviewer = current_account

    if @reviewers_feedback.save
      send_notification_to_developer
      redirect_to "#{story_type_fact_checking_doc_path(@story_type, @story_type.fact_checking_doc)}#reviewers_feedback"
    else
      flash.now[:message] = ''
    end
  end

  private

  def find_fcd_feedback
    @fcd = @story_type.fact_checking_doc
    @reviewers_feedback = @fcd.reviewers_feedback
  end

  def reviewers_feedback_params
    params.require(:reviewers_feedback).permit(:body)
  end

  def send_notification_to_developer
    target = @story_type.developer&.slack
    return if target.nil? || target.identifier.nil?

    message = "##{@story_type.id} #{@story_type.name} -- "\
              "You received the reviewers' feedback by #{current_account.name}. "\
              "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}#reviewers_feedback|Check it>."

    SlackNotificationJob.perform_later(target.identifier, message)
  end
end
