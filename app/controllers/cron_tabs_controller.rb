# frozen_string_literal: true

class CronTabsController < ApplicationController
  after_action :setup_cron_tab, only: %i[create update]

  def new
    @cron_tab = @story_type.build_cron_tab
    render 'form'
  end

  def create
    @story_type.create_cron_tab(cron_tab_params)
    render 'cron_tab'
  end

  def edit
    @cron_tab = @story_type.cron_tab
    render 'form'
  end

  def update
    @story_type.cron_tab.update(cron_tab_params)
    render 'cron_tab'
  end

  private

  def cron_tab_params
    params.require(:cron_tab).permit(:enabled, setup: {})
  end

  def setup_cron_tab
    SetupCronTabJob.perform_later(@story_type)
  end
end
