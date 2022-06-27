# frozen_string_literal: true

module FactoidTypes
  class EditorsFeedbackController < FactoidTypesController
    before_action :find_fcd, only: %i[create confirm]
    before_action :find_feedback_collection, only: %i[create confirm]
    after_action  :send_notification_to_dev, only: :create
    after_action  :send_confirm_to_fc_channel, only: :confirm

    def new; end

    def create
      @feedback = @feedback_collection.build(editors_feedback_params)
      @feedback.editor = current_account
      @feedback.approvable = params[:commit].eql?('approve!')

      if @feedback.save
        redirect_to "#{article_type_fact_checking_doc_path(@factoid_type, @fcd)}#editors_feedback"
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

    def find_feedback_collection
      @feedback_collection = @fcd.editors_feedback
    end

    def editors_feedback_params
      params.require(:editors_feedback).permit(:body)
    end

    def send_notification_to_dev
      developer_pm = @factoid_type.developer&.slack&.identifier
      return if developer_pm.nil?

      message = "*[ LokiC ] <#{article_type_url(@factoid_type)}|Factoid Type ##{@factoid_type.id}> (#{@factoid_type.iteration.name}) | FCD*\n>"

      if params[:commit].eql?('approve!')
        approvable = @fcd.approval_editors
        editors = approvable.map(&:name).join(', ')
        scheduling =
          if approvable.count > 1
            'You can go to create all stories and scheduling'
          else
            'You need one more approval from editors'
          end
        message += "Approved by *#{editors}*. #{scheduling}."
      else
        message += "You received the *editors' feedback* by *#{current_account.name}*. "\
                   "<#{article_type_fact_checking_doc_url(@factoid_type, @factoid_type.fact_checking_doc)}"\
                   '#editors_feedback|Check it>.'
      end

      ::SlackNotificationJob.perform_async(developer_pm, message)
    end

    def send_confirm_to_fc_channel
      fact_checking_channel = @factoid_type.developer&.fact_checking_channel&.name
      return unless fact_checking_channel || @feedback_collection.where(approvable: false).all?(&:confirmed)

      message = "*Updated Factoid Type FCD* ##{@factoid_type.id} "\
                "<#{article_type_fact_checking_doc_url(@factoid_type, @fcd)}|#{@factoid_type.name}>."

      ::SlackNotificationJob.perform_async(fact_checking_channel, message)
    end
  end
end
