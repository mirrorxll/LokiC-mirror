# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, options = {})
    status = true
    message = 'Success. All samples have been created'

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          MiniLokiC::Code.execute(iteration, :creation, options)
        rescue StandardError, ScriptError => e
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

      staging_table = iteration.story_type.staging_table.name
      break if Table.left_count_by_last_iteration(staging_table).zero?
    end

    iteration.update(schedule_counts: schedule_counts(iteration))
  rescue StandardError, ScriptError => e
    status = nil
    message = e
  ensure
    iteration.update(creation: status)
    send_to_action_cable(iteration, :creation, message)
    send_to_slack(iteration, 'CREATION', message)
    iteration.creation
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
