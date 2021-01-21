# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def send_to_action_cable(story_type, iteration, message = {})
    action_cable_send = { status: iteration }.merge(message)
    StoryTypeChannel.broadcast_to(story_type, action_cable_send)
  end

  def send_to_slack(story_type, step, message)
    return unless story_type.developer_slack_id

    msg = "*[ LokiC ] Story Type ##{story_type.id} -- #{step}:*\n"\
          "> #{message}"

    SlackNotificationJob.perform_now(story_type.developer.slack.identifier, msg)
  end
end
