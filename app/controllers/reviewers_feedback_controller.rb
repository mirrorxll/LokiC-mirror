# frozen_string_literal: true

class ReviewersFeedbackController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :find_fcd, only: %i[create approve]
  before_action :find_feedback, only: %i[create approve]

  def new; end

  def create
    @feedback = @feedback_collection.build(reviewers_feedback_params)
    save_and_notify
  end

  def approve
    @feedback = @feedback_collection.build(body: '<p><b>Approved!</b></p>', approvable: true)
    save_and_notify
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def find_feedback
    @feedback_collection = @fcd.reviewers_feedback
  end

  def reviewers_feedback_params
    params.require(:reviewers_feedback).permit(:body)
  end

  def save_and_notify
    @feedback.reviewer = current_account

    if @feedback.save
      send_notification_to_developer
      redirect_to "#{story_type_fact_checking_doc_path(@story_type, @fcd)}#reviewers_feedback"
    else
      flash.now[:message] = ''
    end
  end

  def send_notification_to_developer
    target = @story_type.developer&.slack
    return if target.nil? || target.identifier.nil?

    message = "*##{@story_type.id}* #{@story_type.name} -- "
    message +=
      if action_name.eql?('create')
        "You received the *reviewers' feedback* by #{current_account.name}. "\
        "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}"\
        '#reviewers_feedback|Check it>.'
      else
        "*FCD* was approved by #{current_account.name}. You can send it to editors. "\
        "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}|FCD>."
      end

    SlackNotificationJob.perform_later(target.identifier, message)
  end
end
