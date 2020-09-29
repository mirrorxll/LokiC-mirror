# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_type, options = {})
    MiniLokiC::Code.execute(story_type, :creation, options)
    story_type.update_iteration(
      schedule_counts: schedule_counts(story_type)
    )

    status = true
    message = 'all samples created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(creation: status)
    send_to_action_cable(story_type, creation_msg: message)
    send_to_slack(story_type, message)
  end

  private

  def schedule_counts(story_type)
    counts = {}
    counts[:total] = story_type.iteration.samples.count
    return counts if counts[:total].zero?

    story_type.client_tags.each_with_object(counts) do |row, obj|
      client = row.client
      pubs = client.name.eql?('Metric Media') ? Client.all_mm_publications : client.publications
      counts = pubs.joins(:samples).where(samples: { iteration: story_type.iteration })
                   .group(:publication_id).order('count(publication_id) desc')
                   .count(:publication_id)

      obj[client.name.to_sym] = counts.first[1]
    end
  end
end
