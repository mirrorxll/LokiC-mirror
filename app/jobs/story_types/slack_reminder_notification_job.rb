# frozen_string_literal: true

module StoryTypes
  class SlackReminderNotificationJob < StoryTypeJob
    def perform(story_type, raw_message)
      channel = Rails.env.production? ? 'lokic_reminder_messages' : 'hle_lokic_development_messages'
      url = generate_url(story_type)
      developer_name = story_type.developer.name
      message = "*<#{url}|Story Type ##{story_type.id}> | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

      SlackNotificationJob.perform_now(channel, message)
      return if story_type.developer.slack_identifier.nil?

      message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
      SlackNotificationJob.perform_now(story_type.developer.slack_identifier, "*[ LokiC ]* #{message}")
      record_to_alerts(story_type, 'reminder', raw_message)
    end
  end
end
