# frozen_string_literal: true

class CronTabsController < ApplicationController
  def new
    @cron_tab = @story_type.build_cron_tab
  end

  def create
    @story_type.create_cron_tab(cron_tab_params)
  end

  private

  def cron_tab_params
    params.require(:cron_tab).permit(:enabled, setup: {})
  end
end
