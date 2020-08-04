# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_type, options = {})
    MiniLokiC::Code.execute(story_type, :creation, options)
    schedule_counts = counts(story_type)
    story_type.update_iteration(schedule_counts: schedule_counts)

    status = true
    message = 'all samples created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(creation: status)
    send_to_action_cable(story_type, creation_msg: status)
    send_to_slack(story_type, message)
  end

  private

  def counts(story_type)
    counts = {}
    counts[:total] = story_type.iteration.samples.count

    story_type.client_tags.each_with_object(counts) do |row, obj|
      client = row.client

      publications =
        if client.name.eql?('Metric Media')
          Publication.where('name LIKE :like', like: 'MM -%')
        else
          client.publications
        end

      counts = publications.joins(:samples)
                           .where(samples: { iteration: story_type.iteration })
                           .group(:publication_id).order('count(publication_id) desc')
                           .count(:publication_id)

      obj[client.name.to_sym] = counts.first[1]
    end
  end
end
