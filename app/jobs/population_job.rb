# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type, options)
    MiniLokiC::Code.execute(story_type, :population, options)
    story_type.update_iteration(population: true)
    status = true
    message = 'population success'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(population: status, population_jid: nil)
    send_status(story_type, message)
  end

  private

  def send_status(stp, message)
    StoryTypeChannel.broadcast_to(stp, status: stp.iteration, population_message: message)
    return unless stp.developer_slack_id

    message = "##{stp.id} #{stp.name} -- #{message}"

    SlackNotificationJob.perform_later(
      stp.developer.slack.identifier,
      message
    )
  end
end
