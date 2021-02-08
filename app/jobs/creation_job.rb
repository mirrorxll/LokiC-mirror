# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(iteration, options = {})
    status = true
    message = 'Success. All samples have been created'

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          MiniLokiC::Code.execute(iteration.story_type, :creation, options)
        rescue StandardError => e
          wr.write({ e.class.to_s => e.message }.to_json)
        ensure
          wr.close
        end
      )

      wr.close
      exception = rd.read
      rd.close

      if exception.present?
        klass, message = JSON.parse(exception).to_a.first
        raise Object.const_get(klass), message
      end

      break if Table.left_count_by_last_iteration(iteration.story_type.staging_table.name).zero?
    end

    iteration.update(schedule_counts: schedule_counts(iteration))
  rescue StandardError => e
    status = nil
    message = e
  ensure
    iteration.update(creation: status)
    send_to_action_cable(iteration, creation_msg: message)
    send_to_slack(iteration, 'CREATION', message)
  end

  private

  def schedule_counts(iteration)
    counts = {}
    counts[:total] = iteration.samples.count
    return counts if counts[:total].zero?

    iteration.story_type.client_tags.each_with_object(counts) do |row, obj|
      client = row.client
      pubs = client.name.eql?('Metric Media') ? Client.all_mm_publications : client.publications
      counts = pubs.joins(:samples).where(samples: { iteration: iteration })
                   .group(:publication_id).order('count(publication_id) desc')
                   .count(:publication_id)

      obj[client.name.to_sym] = counts.first[1]
    end
  end
end
