# frozen_string_literal: true

module StoryTypes
  class CreationJob < StoryTypesJob
    def perform(iteration, account, options = {})
      status = true
      message = 'Success. All stories have been created'
      story_type = iteration.story_type
      story_type.sidekiq_break.update!(cancel: false)
      publication_ids = story_type.publication_pl_ids
      options[:iteration] = iteration
      options[:publication_ids] = publication_ids
      options[:type] = 'story'

      loop do
        rd, wr = IO.pipe
        break if story_type.sidekiq_break.reload.cancel || Table.all_stories_created_by_iteration?(staging_table, publication_ids)

        # break if story_type.sidekiq_break.reload.cancel

        Process.wait(
          fork do
            rd.close
            MiniLokiC::StoryTypeCode[iteration.story_type].execute(:creation, options)
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

        staging_table = story_type.staging_table.name
      end

      iteration.update!(schedule_counts: schedule_counts(iteration), current_account: account)

      if story_type.sidekiq_break.reload.cancel
        status = nil
        message = 'Canceled'
      end

      false
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
      true
    ensure
      iteration.update!(creation: status, current_account: account)
      story_type.sidekiq_break.update!(cancel: false)
      send_to_action_cable(story_type, :stories, message)

      StoryTypes::SlackNotificationJob.perform_now(iteration, 'creation', message)
    end

    private

    def schedule_counts(iteration)
      counts = Hash.new(0)
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
end
