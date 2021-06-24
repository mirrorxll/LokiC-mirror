# frozen_string_literal: true

class EditorsFeedbackController < ApplicationController
  before_action :render_400_developer, only: %i[new create], if: :developer?
  before_action :render_400_editor, only: :confirm, if: :editor?
  before_action :find_fcd, only: %i[create confirm]
  before_action :find_feedback_collection, only: %i[create confirm]
  after_action  :send_notification_to_dev, only: :create
  after_action  :fcd_approved_to_history,  only: :create
  after_action  :send_confirm_to_fc_channel, only: :confirm

  def new; end

  def create
    @feedback = @feedback_collection.build(editors_feedback_params)
    @feedback.editor = current_account
    @feedback.approvable = params[:commit].eql?('approve!')

    if @feedback.save
      redirect_to "#{story_type_fact_checking_doc_path(@story_type, @fcd)}#editors_feedback"
    else
      flash.now[:message] = ''
    end
  end

  def confirm
    @feedback = @feedback_collection.find(params[:id])
    render_400 and return if @feedback.confirmed

    @feedback.update(confirmed: true)
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def find_feedback_collection
    @feedback_collection = @fcd.editors_feedback
  end

  def editors_feedback_params
    params.require(:editors_feedback).permit(:body)
  end

  def send_notification_to_dev
    developer_pm = @story_type.developer&.slack&.identifier
    return if developer_pm.nil?

    message = "*[ LokiC ] <#{story_type_url(@story_type)}|STORY TYPE ##{@story_type.id}> (#{@story_type.iteration.name}) | FCD*\n>"

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
                "<#{story_type_fact_checking_doc_url(@story_type, @story_type.fact_checking_doc)}"\
                '#editors_feedback|Check it>.'
    end

    SlackNotificationJob.perform_later(developer_pm, message)
  end

  def send_confirm_to_fc_channel
    fc_channel = @story_type.developer&.fc_channel&.name
    return unless fc_channel
    return unless @feedback_collection.where(approvable: false).all?(&:confirmed)

    message = "*Updated FCD* ##{@story_type.id} "\
              "<#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>."

    SlackNotificationJob.perform_later(fc_channel, message)
  end

  def fcd_approved_to_history
    return if @fcd.approval_editors < 2

    notes = "fact checking doc approved by #{@fcd.approval_editors.map(&:name).join(', ')}"
    record_to_change_history(@story_type, 'fact checking doc approved', notes)
  end
end
