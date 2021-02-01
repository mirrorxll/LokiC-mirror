# frozen_string_literal: true

class CronTabsController < ApplicationController
  def new
    @cron_tab = @story_type.build_cron_tab
  end
end

pl = Pipeline[:production].update_story(573162866, story_tag_ids: [])
