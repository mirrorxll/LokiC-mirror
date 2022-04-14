# frozen_string_literal: true

module StoryTypes
  class SlackCronTabSetupNotificationJob < StoryTypesJob
    def perform(story_type_id, raw_message)
      story_type = StoryType.find(story_type_id)
      story_type_dev = story_type.developer
      url = generate_url(story_type)
      message = "*<#{url}|Story Type ##{story_type.id}> | Crontab | #{story_type_dev.name}*\n>#{raw_message}"

      ::SlackNotificationJob.perform_async('lokic_story_type_messages', message)
      return if story_type_dev.slack_identifier.nil?

      message = message.gsub(/#{Regexp.escape(" | #{story_type_dev.name}")}/, '')
      ::SlackNotificationJob.perform_async(story_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
    end
  end
end
