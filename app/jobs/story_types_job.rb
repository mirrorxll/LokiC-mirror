# frozen_string_literal: true

class StoryTypesJob < ApplicationJob
  sidekiq_options queue: :story_type

  private

  def send_to_action_cable(story_type, section, message)
    message_to_send = {
      iteration_id: story_type.iteration.id,
      message: {
        key: section,
        section => message
      }
    }

    StoryTypeChannel.broadcast_to(story_type, message_to_send)
  end

  def send_report_to_editors_slack(iteration, url)
    story_type = iteration.story_type
    return unless story_type.developer_fc_channel_name

    message = "Exported Stories *##{story_type.id} #{story_type.name} (#{iteration.name})*\n#{url}"
    SlackNotificationJob.new.perform(story_type.developer_fc_channel_name, message)
  end

  def opportunities_attached?(story_type, iteration)
    publication_ids = iteration.stories.pluck(:publication_id).uniq
    st_opportunities = story_type.opportunities.where(publication_id: publication_ids)
    return true unless st_opportunities.any? { |st_o| st_o[:opportunity_id].nil? }

    url = generate_url(story_type)
    developer = story_type.developer.slack_identifier
    manager = Account.find_by(first_name: 'Sergey', last_name: 'Burenkov').slack_identifier
    message = "[ LokiC ] <#{url}|Story Type ##{story_type.id}> has "\
              'clients/publications without attached opportunities. Export was blocked!'
    flash_message = {
      iteration_id: iteration.id,
      message: {
        key: :export,
        export: 'Story Type has clients/publications without attached opportunities.'
      }
    }
    # flash message
    StoryTypeChannel.broadcast_to(story_type, flash_message)
    # slack message
    ::SlackNotificationJob.new.perform(developer, message)
    ::SlackNotificationJob.new.perform(manager, message)

    false
  end
end
