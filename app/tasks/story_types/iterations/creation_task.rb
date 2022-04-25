# frozen_string_literal: true

module StoryTypes
  module Iterations
    class CreationTask < StoryTypesTask
      def perform(iteration_id, account_id)
        iteration = StoryTypeIteration.find(iteration_id)
        account = Account.find(account_id)
        status = true
        message = 'Success. All stories have been created'
        story_type = iteration.story_type
        staging_table = story_type.staging_table.name
        story_type.sidekiq_break.update!(cancel: false)
        publication_ids = story_type.publication_pl_ids

        options = {
          iteration: iteration,
          publication_ids: publication_ids,
          type: 'story'
        }

        loop do
          if story_type.sidekiq_break.reload.cancel ||
             Table.all_stories_created_by_iteration?(staging_table, publication_ids)
            break
          end

          MiniLokiC::StoryTypeCode[iteration.story_type].execute(:creation, options)
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

        SlackIterationNotificationTask.new.perform(iteration.id, 'creation', message)
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
end
