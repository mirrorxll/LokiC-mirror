# frozen_string_literal: true

module StoryTypes
  class SlackNotificationJob < StoryTypesJob
    def perform(iteration, step, raw_message, developer = nil)
      story_type = iteration.story_type
      story_type_dev = developer || story_type.developer
      # channel = Rails.env.production? ? 'lokic_story_type_messages' : 'hle_lokic_development_messages'
      channel = 'U02JWAHN88M'

      url = generate_url(story_type)
      progress_step = step.in?(%w[developer]) ? '' : "| #{step.capitalize}"
      developer_name = story_type_dev.name
      message = "*<#{url}|Story Type ##{story_type.id}> #{iteration.name.nil? ? '' : " (#{iteration.name})"} #{progress_step}"\
                " | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

      record_to_alerts(story_type, step, raw_message)

      ::SlackNotificationJob.perform_now(channel, message)
      return if story_type_dev.slack_identifier.nil? || step.eql?('status')

      message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
      ::SlackNotificationJob.perform_now(story_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
    end
  end
end
