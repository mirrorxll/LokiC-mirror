# frozen_string_literal: true

class CronTabsController < ApplicationController
  def new
    @cron_tab = @story_type.build_cron_tab
  end
end
