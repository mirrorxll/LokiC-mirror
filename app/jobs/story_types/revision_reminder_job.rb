# frozen_string_literal: true

module StoryTypes
  class RevisionReminderJob < ApplicationJob
    def perform
      Template.with_soon_revision.map { |template| template.update(revised: false) }
      Template.revision_needed.each do |template|
        story_type = template.templateable
        url = generate_url(story_type)
        channel = Rails.env.production? ? 'lokic_editors' : 'hle_lokic_development_messages'
        message = if template.revision > Date.today
                    "<#{url}|Story Type ##{story_type.id}> needs to revise static year #{template.static_year}." \
                    " Final revision date - #{template.revision}."
                  else
                    "<#{url}|Story Type ##{story_type.id}> had to be revised on #{template.revision}. Do it now to" \
                    ' unblock export!'
                  end

        ::SlackNotificationJob.perform_now(channel, message)
      end
    end
  end
end
