# frozen_string_literal: true

class ReviewersFeedbackController < ApplicationController
  before_action :render_400,          unless: :manager?
  before_action :find_fcd,            only: %i[create confirm]
  before_action :find_feedback,       only: %i[create confirm]
  after_action  :send_notifications,  only: :create

  def new; end

  def create
    @feedback = @feedback_collection.build(reviewers_feedback_params)
    @feedback.reviewer = current_account
    @feedback.approvable = true if params[:commit].eql?('approve!')

    if @feedback.save
      redirect_to "#{story_type_fact_checking_doc_path(@story_type, @fcd)}#reviewers_feedback"
    else
      flash.now[:message] = ''
    end
  end

  def confirm

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

  def send_notifications
    fcd_channel = @story_type.developer&.fc_channel&.name
    developer_pm = @story_type.developer&.slack&.identifier
    return if developer_pm.nil? || fcd_channel.nil?

    if params[:commit].eql?('approve!')
      note = ActionView::Base.full_sanitizer.sanitize(@feedback.body)
      message = "*FCD ##{@story_type.id}* "\
                "<#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>.\n"\
                "#{@feedback.body.present? ? "*Reviewer's Note*: #{note}" : ''}"
      SlackNotificationJob.perform_later(fcd_channel, message)

      message = "*##{@story_type.id} #{@story_type.name}* -- FCD was approved by #{current_account.name} "\
                "and sent to *#{fcd_channel}* channel."
    else
      message = "*##{@story_type.id} #{@story_type.name}* -- You received the *reviewers' feedback* by #{current_account.name}. "\
                "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}"\
                '#reviewers_feedback|Check it>.'
    end

    SlackNotificationJob.perform_later(developer_pm, message)
  end
end
