# frozen_string_literal: true

module StoryTypes
  class SlackReminderNotificationTask < StoryTypesTask
    def perform(story_type_id, raw_message)
      story_type = StoryType.find(story_type_id)
      url = generate_url(story_type)
      developer_name = story_type.developer.name
      message = "*<#{url}|Story Type ##{story_type.id}> | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

      ::SlackNotificationTask.new.perform('lokic_reminder_messages', message)
      return if story_type.developer.slack_identifier.nil?

      message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
      ::SlackNotificationTask.new.perform(story_type.developer.slack_identifier, "*[ LokiC ]* #{message}")
      record_to_alerts(story_type, 'reminder', raw_message)
    end
  end
end
