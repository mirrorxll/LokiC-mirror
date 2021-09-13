# frozen_string_literal: true

class SlackNotificationJob < ApplicationJob
  queue_as :lokic

  def perform(identifier, msg, thread_ts = nil)
    retry_counter = 0

    params = {
      channel: identifier,
      text: msg,
      as_user: true,
      thread_ts: thread_ts
    }

    begin
      Slack::Web::Client.new.chat_postMessage(params)
    rescue Slack::Web::Api::Errors::TimeoutError
      retry_counter += 1

      if retry_counter <= 3
        sleep(retry_counter**2)
        retry
      end
    end
  end
end
