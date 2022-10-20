# frozen_string_literal: true

module StoryTypes
  class BackdateExportTask < StoryTypesTask
    def perform
      stop_at = (Time.now + 82_800)
      report_dirs = "#{Dir.home}/reports/story_types/backdate_exports"
      report_path = "#{report_dirs}/#{DateTime.now.to_s.gsub(/[^0-9]/, '')}.txt"
      iteration_ids = Story.select(:story_type_iteration_id).distinct.where("
         created_at > '2021-08-30' AND
         published_at < (current_date() - 2) AND
         backdated = 1
      ").to_a.map(&:story_type_iteration_id)

      FileUtils.mkpath(report_dirs)
      Slack::Web::Client.new.chat_postMessage(channel: 'U024ZKRR8AE', text: "Backdate export has been started #{PL_TARGET}")

      loop do
        iter_id = iteration_ids.shift
        break if iter_id.nil? || Time.now >= stop_at

        options = { backdated: { report_path: report_path, stop_at: stop_at }, threads_count: 3 }
        iteration = StoryTypeIteration.find(iter_id)

        Samples[PL_TARGET].export!(iteration, options)
      end

      Slack::Web::Client.new.chat_postMessage(channel: 'U024ZKRR8AE', text: "Backdate export has been finished  #{PL_TARGET}")
    end
  end
end
