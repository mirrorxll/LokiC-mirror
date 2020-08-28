# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  before_action :find_fcd, except: :template

  def show
    @tab_title = "FCD ##{@story_type.id} #{@story_type.name}"
  end

  def edit; end

  def save; end

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
  end

  def send_to_slack_channel
    target = @story_type.developer&.slack
    render_400 and return if target.nil? || target.identifier.nil?

    @info = send_to_slack_params
    message = message_to_slack(@info)

    SlackNotificationJob.perform_later('notifications_test', message)
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def fcd_params
    params.require(:fact_checking_doc).permit(:body)
  end

  def send_to_slack_params
    params.require(:slack_message).permit(:channel, :note)
  end

  def message_to_slack(info)
    "*FCD* ##{@story_type.id} <#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>.\n"\
    "*Developer:* #{@story_type.developer.name}.\n"\
    "#{info[:note].present? ? "*Note*: #{info[:note]}" : ''}"
  end
end
