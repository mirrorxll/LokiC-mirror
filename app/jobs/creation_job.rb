# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account, options = {})
    status = true
    message = 'Success. All stories have been created'
    publication_ids = iteration.story_type.publication_pl_ids.join(',')
    options[:iteration] = iteration
    options[:publication_ids] = publication_ids

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          MiniLokiC::Code[iteration.story_type].execute(:creation, options)
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
      break if Table.all_created_by_last_iteration?(staging_table, publication_ids)
    end

    iteration.update!(schedule_counts: schedule_counts(iteration), current_account: account)

    true
  rescue StandardError, ScriptError => e
    status = nil
    message = e.message
  ensure
    iteration.update!(creation: status, current_account: account)
    send_to_action_cable(iteration, :stories, message)
    SlackStoryTypeNotificationJob.perform_now(iteration, 'creation', message)
  end

  private

  def schedule_counts(iteration)
    counts = {}
    counts[:total] = iteration.stories.count
    return counts if counts[:total].zero?

    iteration.story_type.clients_publications_tags.each_with_object(counts) do |row, obj|
      client = row.client
      pubs = client.publications
      counts = pubs.joins(:stories).where(stories: { iteration: iteration })
                   .group(:publication_id).order('count(publication_id) desc')
                   .count(:publication_id)
      next if counts.empty?

      obj[client.name.to_sym] = counts.first[1]
    end
  end
end
