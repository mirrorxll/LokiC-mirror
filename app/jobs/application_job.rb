# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def send_to_action_cable(iteration, message = {})
    action_cable_send = { status: iteration }.merge(message)
    StoryTypeChannel.broadcast_to(iteration.story_type, action_cable_send)
  end

  def send_to_slack(iteration, step, raw_message)
    story_type = iteration.story_type
    return unless story_type.developer_slack_id

    message =
      "*[ LokiC ] #{step} | STORY TYPE ##{story_type.id} (#{iteration.name})*\n#{raw_message}".gsub("\n", "\n>")
    SlackNotificationJob.perform_now(story_type.developer.slack.identifier, message)

    channel = Rails.env.production? ? 'hle_lokic_messages' : 'notifications_test'
    SlackNotificationJob.perform_now(channel, message)
  end
end
