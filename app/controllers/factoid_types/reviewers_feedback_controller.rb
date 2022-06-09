# frozen_string_literal: true

module FactoidTypes
  class ReviewersFeedbackController < FactoidTypesController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :find_fcd,                       only: %i[create confirm]
    before_action :find_feedback,                  only: %i[create confirm]
    after_action  :send_notifications,             only: :create
    after_action  :send_confirm_to_review_channel, only: :confirm

    def new; end

    def create
      @feedback = @feedback_collection.build(reviewers_feedback_params)
      @feedback.reviewer = current_account
      @feedback.approvable = params[:commit].eql?('approve!')

      if @feedback.save
        redirect_to "#{article_type_fact_checking_doc_path(@factoid_type, @fcd)}#reviewers_feedback"
      else
        flash.now[:message] = ''
      end
    end

    def confirm
      @feedback = @feedback_collection.find(params[:id])
      render_403 and return if @feedback.confirmed

      @feedback.update!(confirmed: true)
    end

    private

    def find_fcd
      @fcd = @factoid_type.fact_checking_doc
    end

    def find_feedback
      @feedback_collection = @fcd.reviewers_feedback
    end

    def reviewers_feedback_params
      params.require(:reviewers_feedback).permit(:body)
    end

    def send_notifications
      fcd_channel = @factoid_type.developer&.fact_checking_channel&.name
      developer_pm = @factoid_type.developer&.slack&.identifier
      return if developer_pm.nil? || fcd_channel.nil?

      message_to_dev = "*[ LokiC ] <#{article_type_url(@factoid_type)}|Factoid Type ##{@factoid_type.id}> (#{@factoid_type.iteration.name}) | FCD*\n>"

      if params[:commit].eql?('approve!')
        note = ActionView::Base.full_sanitizer.sanitize(@feedback.body)
        message_to_fc_channel = "*FCD ##{@factoid_type.id}* "\
                                "<#{article_type_fact_checking_doc_url(@factoid_type, @fcd)}|#{@factoid_type.name}>.\n"\
                                "#{@feedback.body.present? ? "*Reviewer's Note*: #{note}" : ''}"
        ::SlackNotificationJob.perform_async(fcd_channel, message_to_fc_channel)

        message_to_dev += "Approved by *#{current_account.name}* and sent to *#{fcd_channel}* channel"
      else
        message_to_dev += "You received the *reviewers' feedback* by *#{current_account.name}*. "\
                         "<#{article_type_fact_checking_doc_url(@factoid_type, @factoid_type.fact_checking_doc)}"\
                         '#reviewers_feedback|Check it>.'
      end

      ::SlackNotificationJob.perform_async(developer_pm, message_to_dev)
    end

    def send_confirm_to_review_channel
      reviewer =
        if @feedback.reviewer.slack
          "<@#{@feedback.reviewer.slack.identifier}>"
        else
          @feedback.reviewer.name
        end

      message = "#{reviewer} the developer confirms your feedback. "\
                "<#{article_type_fact_checking_doc_url(@factoid_type, @factoid_type.fact_checking_doc)}"\
                '#reviewers_feedback|Check it>.'

      ::SlackNotificationJob.perform_async('hle_reviews_queue', message, @fcd.slack_message_ts)
    end
  end
end
