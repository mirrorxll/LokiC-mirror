# frozen_string_literal: true

module StoryTypes
  class PurgeExportJob < StoryTypesJob
    def perform(iteration, account)
      status = false
      message = 'Success'
      story_type = iteration.story_type
      SidekiqBreak.create_with(cancel: false).find_or_create_by(story_type: story_type)

      loop do
        rd, wr = IO.pipe

        Process.wait(
          fork do
            rd.close

            Samples[PL_TARGET].remove!(iteration)
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

        break if iteration.stories.reload.exported.count.zero? || story_type.reload.sidekiq_break.cancel
      end

      Process.wait(
        fork do
          iteration.exported&.destroy
          iteration.production_removals.last.update!(status: true)

          note = MiniLokiC::Formatize::Numbers.to_text(iteration.stories.ready_to_export.count)
          record_to_change_history(story_type, 'removed from pipeline', note, account)

          old_status = story_type.status.name
          last_iteration = story_type.reload.iterations.last.eql?(iteration)
          changeable_status = !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])

          if !old_status.eql?('in progress') && last_iteration && changeable_status
            story_type.update!(status: Status.find_by(name: 'in progress'), last_status_changed_at: Time.now, current_account: account)
          end
        end
      )
      if story_type.sidekiq_break.cancel
        status = nil
        message = 'Canceled'
      end

    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_export: status, export: nil)
      story_type.sidekiq_break.update(cancel: false)
      send_to_action_cable(iteration.story_type, :export, message)
      StoryTypes::SlackNotificationJob.perform_now(iteration, 'remove from pl', message)
    end
  end
end
