# frozen_string_literal: true

class SlackNotificationJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(identifier, msg, thread_ts = nil)
    channel = Rails.env.production? ? identifier : 'hle_lokic_development_messages'

    params = {
      channel: channel,
      text: msg,
      as_user: true,
      thread_ts: thread_ts
    }

    retry_counter = 0

    begin
      Slack::Web::Client.new.chat_postMessage(params)
    rescue Slack::Web::Api::Errors::SlackError
      retry_counter += 1

      if retry_counter <= 3
        sleep(retry_counter**2)
        retry
      end
    end
  end
end
