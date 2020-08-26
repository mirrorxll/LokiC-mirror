# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  before_action :find_fcd, except: :template

  def show
    @tab_title = "FCD ##{@story_type.id} #{@story_type.name}"
  end

  def edit; end

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
    @to_slack_info = send_to_slack_params

    msg = "*FCD* ##{@story_type.id} <#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>.\n"
    msg += @to_slack_info[:channel].eql?('hle_reviews_queue') ? "*Developer:* #{@story_type.developer.name}.\n" : ''
    msg += @to_slack_info[:note].present? ? "*Note*: #{@to_slack_info[:note]}" : ''

    SlackNotificationJob.perform_later('notifications_test', msg)
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

  def message
    "*FCD* ##{@story_type.id} <#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>.\n"
  end
end
