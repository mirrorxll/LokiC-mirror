# frozen_string_literal: true

module StoryTypes
  module Iterations
    class PurgeExportTask < StoryTypesTask
      def perform(iteration_id, account_id)
        iteration = StoryTypeIteration.find(iteration_id)
        account = Account.find(account_id)
        status = false
        message = 'Success'
        story_type = iteration.story_type
        story_type.sidekiq_break.update!(cancel: false)

        loop do
          break if iteration.stories.reload.exported.count.zero? || story_type.sidekiq_break.reload.cancel

          Samples[PL_TARGET].remove!(iteration)
        end

        iteration.exported&.destroy
        story_type.update!(last_export: story_type.exported_story_types.last&.date_export)

        StoryTypes::Iterations::SetNextExportDateTask.new.perform(story_type.id)

        iteration.production_removals.last.update!(status: true)

        note = MiniLokiC::Formatize::Numbers.to_text(iteration.stories.ready_to_export.count)
        record_to_change_history(story_type, 'removed from pipeline', note, account)

        old_status = story_type.status.name
        last_iteration = story_type.reload.iterations.last.eql?(iteration)
        changeable_status = !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])

        StoryTypes::Iterations::SetMaxTimeFrameTask.new.perform(story_type.id)

        if !old_status.eql?('in progress') && last_iteration && changeable_status
          story_type.update!(status: Status.find_by(name: 'in progress'), last_status_changed_at: Time.now, current_account: account)
        end

        if story_type.sidekiq_break.cancel
          status = nil
          message = 'Canceled'
        end
      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        iteration.update!(purge_export: status, export: nil)
        story_type.sidekiq_break.update!(cancel: false)
        send_to_action_cable(iteration.story_type, :export, message)
        SlackIterationNotificationTask.new.perform(iteration.id, 'remove from pl', message)
      end
    end
  end
end
