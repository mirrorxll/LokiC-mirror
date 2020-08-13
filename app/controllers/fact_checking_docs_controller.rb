# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  before_action :find_fcd, except: :template
  before_action :update_fcd, only: %i[update save]
  before_action :message, only: :send_to_fc_channel

  def show; end

  def edit; end

  def update
    if @fcd.errors.any?
      render :edit
    else
      redirect_to story_type_fact_checking_doc_path(@story_type, @fcd)
    end
  end

  def template
    @template = @story_type.template
  end

  def save; end

  def send_to_fc_channel
    SlackNotificationJob.perform_later('notifications_test', message)
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def update_fcd
    @fcd.update(fcd_params)
  end

  def fcd_params
    params.require(:fact_checking_doc).permit(:body)
  end

  def message
    "FCD ##{@story_type.id} <#{story_type_fact_checking_doc_url(@story_type, @fcd)}|#{@story_type.name}>."
  end
end
