# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_type, options = {})
    status = true
    message = 'ALL SAMPLES HAVE BEEN CREATED'
    iteration = story_type.iteration
    exception = nil

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          MiniLokiC::Code.execute(story_type, :creation, options)
        rescue StandardError => e
          wr.write %({"#{e.class}":"#{e.message}"})
        ensure
          wr.close
        end
      )

      wr.close
      p exception = rd.read
      rd.close

      all_stories_created = Table.left_count_by_last_iteration(story_type.staging_table.name).zero?
      break if all_stories_created || exception.present?
    end

    if exception.present?
      klass, message = JSON.parse(exception).to_a.first
      raise Object.const_get(klass), message
    end

    iteration.update(schedule_counts: schedule_counts(story_type))
  rescue StandardError => e
    status = nil
    message = e
  ensure
    iteration.update(creation: status)
    send_to_action_cable(story_type, iteration, creation_msg: message)
    send_to_slack(story_type, 'creation', message)
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
