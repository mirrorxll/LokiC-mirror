module StoryTypes
  class RevisionReminderJob < ApplicationJob
    def perform
      templates = Template.where.not(revision: nil).where('revision <= ?', Date.today + 1.week)
      pp templates
      templates.each do |template|
        story_type = template.templateable
        # channel = story_type.editor.slack_identifier
        channel = story_type.developer.slack_identifier
        if template.revision >= Date.today
          message = "StoryType #{story_type.id} need's to revision static year #{template.static_year}.\n" \
                    "Final date to be revised - #{template.revision}."
        else

          message = "StoryType #{story_type.id} had to be revisited on #{template.revision}. Do it now to unblock export!"
        end
        ::SlackNotificationJob.perform_now(channel, message)
      end
    end
  end
end
