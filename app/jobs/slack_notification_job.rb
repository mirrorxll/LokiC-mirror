# frozen_string_literal: true

class SlackNotificationJob < ApplicationJob
  queue_as :slack_api

  def perform(identifier, msg, thread_ts = nil)
    params = {
      channel: identifier,
      text: msg,
      as_user: true,
      thread_ts: thread_ts
    }

    Slack::Web::Client.new.chat_postMessage(params)
  end
end
