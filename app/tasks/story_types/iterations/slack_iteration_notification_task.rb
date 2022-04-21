# frozen_string_literal: true

module StoryTypes
  module Iterations
    class SlackIterationNotificationTask < StoryTypesTask
      def perform(iteration_id, step, raw_message, developer_id = nil)
        iteration = StoryTypeIteration.find(iteration_id)
        story_type = iteration.story_type
        story_type_dev = Account.find_by(id: developer_id) || story_type.developer

        url = generate_url(story_type)
        progress_step = step.in?(%w[developer]) ? '' : "| #{step.capitalize}"
        developer_name = story_type_dev.name
        message = "*<#{url}|Story Type ##{story_type.id}> #{iteration.name.nil? ? '' : " (#{iteration.name})"} #{progress_step}"\
                  " | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

        record_to_alerts(story_type, step, raw_message)

        ::SlackNotificationTask.new.perform('lokic_story_type_messages', message)
        return if story_type_dev.slack_identifier.nil? || step.eql?('status')

        message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
        ::SlackNotificationTask.new.perform(story_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
      end
    end
  end
end
