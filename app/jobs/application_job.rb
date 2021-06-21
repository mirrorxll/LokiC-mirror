# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def send_to_action_cable(iteration, section, message)
    message_to_send = { iteration_id: iteration.id, message: { key: section, section => message } }

    StoryTypeChannel.broadcast_to(iteration.story_type, message_to_send)
  end

  def send_to_dev_slack(iteration, step, raw_message)
    story_type = iteration.story_type
    return unless story_type.developer_slack_id

    iteration_name = step.eql?(:reminder) ? '' : "(#{iteration.name}) "
    message =
      "*[ LokiC ] STORY TYPE ##{story_type.id} #{iteration_name}| #{step}*\n#{raw_message}".gsub("\n", "\n>")

    SlackNotificationJob.perform_now(story_type.developer.slack.identifier, message)

    channel = Rails.env.production? ? 'hle_lokic_messages' : '#lokic_development_messages'

    SlackNotificationJob.perform_now(channel, message)
  end

  def send_rprt_to_editors_slack(iteration, url)
    story_type = iteration.story_type
    return unless story_type.developer_fc_channel_name

    channel = Rails.env.production? ? story_type.developer_fc_channel_name : '#lokic_development_messages'
    message = "Exported Stories *##{story_type.id} #{story_type.name} (#{iteration.name})*\n#{url}"
    SlackNotificationJob.perform_now(channel, message)
  end
end
