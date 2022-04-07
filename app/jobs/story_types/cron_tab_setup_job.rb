# frozen_string_literal: true

module StoryTypes
  class CronTabSetupJob < ApplicationJob
    queue_as :cron_tab

    def perform
      `whenever --update-crontab --set environment=#{Rails.env}`
    end
  end
end
