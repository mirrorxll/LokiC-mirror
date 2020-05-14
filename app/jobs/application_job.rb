# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  private

  def send_status(stp, message)
    StoryTypeChannel.broadcast_to(stp, status: stp.iteration, population_message: message)
    return unless stp.developer_slack_id

    message = "##{stp.id} #{stp.name} -- #{message}"

    SlackNotificationJob.perform_later(
      stp.developer.slack.identifier,
      message
    )
  end
end
