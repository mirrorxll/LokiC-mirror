# frozen_string_literal: true

class SlackNotificationJob < ApplicationJob
  queue_as :slack_api

  def perform(identifier, msg)
    Slack::Web::Client.new.chat_postMessage(
      channel: identifier,
      text: msg,
      as_user: true
    )
  end
end
