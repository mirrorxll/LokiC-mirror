# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  private

  def send_status(stp, message = {})
    action_cable_send = { status: stp.iteration }.merge(message)
    StoryTypeChannel.broadcast_to(stp, action_cable_send)
    return unless stp.developer_slack_id

    job = "##{stp.id} #{stp.name} -- #{message.values.first}"

    SlackNotificationJob.perform_later(
      stp.developer.slack.identifier,
      job
    )
  end
end
