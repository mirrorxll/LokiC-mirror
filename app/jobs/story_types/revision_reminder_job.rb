# frozen_string_literal: true

module StoryTypes
  class RevisionReminderJob < ApplicationJob
    def perform
      Template.revision_needed.each do |template|
        template.update!(revised: false)
        story_type = template.templateable
        data_set = story_type.data_set
        story_type_url = generate_url(story_type)
        data_set_url = generate_url(data_set)
        message = if template.revision > Date.today
                    "<#{story_type_url}|Story Type ##{story_type.id}>(<#{data_set_url}|#{data_set.name}>) needs to " \
                    "revise static year #{template.static_year}. Final revision date - #{template.revision}."
                  else
                    "<#{story_type_url}|Story Type ##{story_type.id}>(<#{data_set_url}|#{data_set.name}>) had to be " \
                    " revised on #{template.revision}. Do it now to unblock export!"
                  end

        ::SlackNotificationJob.perform_now('lokic_editors', message)
      end
    end
  end
end
