# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def send_to_action_cable(stp, message = {})
    action_cable_send = { status: stp.iteration }.merge(message)
    StoryTypeChannel.broadcast_to(stp, action_cable_send)
  end

  def send_to_slack(stp, message)
    return unless stp.developer_slack_id

    SlackNotificationJob.perform_later(
      stp.developer.slack.identifier,
      "##{stp.id} #{stp.name} (iteration: #{stp.iteration.name}) -- #{message}"
    )
  end
end
