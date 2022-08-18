# frozen_string_literal: true

module StoryTypes
  class BackdateExportTask < StoryTypesTask
    def perform
      Slack::Web::Client.new.chat_postMessage(channel: 'U024ZKRR8AE', text: "Backdate export has been started #{PL_TARGET}")

      stop_at = (Time.now + 82_800)
      iteration_ids = Story.select(:story_type_iteration_id).distinct.where(
        "created_at > '2021-08-30' AND
         published_at < (current_date() - 2) AND
         backdated = 1"
      ).to_a.map(&:story_type_iteration_id)

      loop do
        iter_id = iteration_ids.shift
        break if iter_id.nil? || Time.now >= stop_at

        iteration = StoryTypeIteration.find(iter_id)
        options = { threads_count: 2, backdated: { stop_at: stop_at } }

        Samples[PL_TARGET].export!(iteration, options)
      end

      Slack::Web::Client.new.chat_postMessage(channel: 'U024ZKRR8AE', text: "Backdate export has been finished  #{PL_TARGET}")
    end
  end
end
