# frozen_string_literal: true

class CronTabsController < ApplicationController
  before_action :cron_tab
  after_action :setup_cron_tab, only: %i[create update]

  def edit
    render 'form'
  end

  def update
    @cron_tab.update!(cron_tab_params)
    render 'cron_tab'
  end

  private

  def cron_tab
    @cron_tab = @story_type.cron_tab
  end

  def cron_tab_params
    attributes = params.require(:cron_tab).permit(:enabled, setup: {})
    attributes[:current_account] = current_account
    attributes
  end

  def setup_cron_tab
    CronTabSetupJob.perform_later(@story_type)
  end
end
