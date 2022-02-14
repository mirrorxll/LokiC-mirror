# frozen_string_literal: true

class StoryTypesJob < ApplicationJob
  queue_as :story_type

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
    SlackNotificationJob.perform_now(story_type.developer_fc_channel_name, message)
  end
end
