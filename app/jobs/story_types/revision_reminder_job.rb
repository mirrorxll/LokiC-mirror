# frozen_string_literal: true

module StoryTypes
  class RevisionReminderJob < ApplicationJob
    def perform
      Template.revision_needed.each do |template|
        template.update(revised: false)
        story_type = template.templateable
        url = generate_url(story_type)

        message =
          if template.revision > Date.today
            "<#{url}|Story Type ##{story_type.id}> needs to revise static year #{template.static_year}." \
            " Final revision date - #{template.revision}."
          else
            "<#{url}|Story Type ##{story_type.id}> had to be revised on #{template.revision}. Do it now to" \
            ' unblock export!'
          end

        ::SlackNotificationJob.perform_now('lokic_editors', message)
      end
    end
  end
end
