# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :save
  before_action :find_fcd, except: :template

  def show
    @tab_title = "LokiC::FCD ##{@story_type.id} #{@story_type.name}"
  end

  def edit; end

  def save
    @fcd.update(fcd_params)
  end

  def update
    @fcd.update(fcd_params)

    if @fcd.errors.any?
      render :edit
    else
      redirect_to story_type_fact_checking_doc_path(@story_type, @fcd)
    end
  end

  def template
    @template = @story_type.template

    respond_to do |format|
      format.js { render 'template' }
      format.html { redirect_to story_type_template_path(@story_type, @template) }
    end
  end

  def send_to_reviewers_channel
    response = SlackNotificationJob.perform_now('hle_reviews_queue', message_to_slack)
    @fcd.update(slack_message_ts: response[:ts])
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def fcd_params
    params.require(:fact_checking_doc).permit(:body)
  end

  def send_to_reviewers_params
    params.require(:slack_message).permit(:channel, :note)
  end

  def message_to_slack
    info = send_to_reviewers_params

    "*FCD* ##{@story_type.id} <#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>.\n"\
    "*Developer:* #{@story_type.developer.name}.\n"\
    "#{info[:note].present? ? "*Note*: #{info[:note]}" : ''}"
  end
end
