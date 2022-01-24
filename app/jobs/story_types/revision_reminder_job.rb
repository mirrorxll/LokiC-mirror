# frozen_string_literal: true

module StoryTypes
  class RevisionReminderJob < ApplicationJob
    def perform
      Template.revision_needed.each do |template|
        story_type = template.templateable
        channel = story_type.editor.slack_identifier
        message = if template.revision > Date.today
                    "StoryType #{story_type.id} need's to revise static year #{template.static_year}.\n" \
                    "Final revision date - #{template.revision}."
                  else
                    "StoryType #{story_type.id} had to be revised on #{template.revision}. Do it now to unblock export!"
                  end

        ::SlackNotificationJob.perform_now(channel, message)
      end
    end
  end
end
