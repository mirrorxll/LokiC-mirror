# frozen_string_literal: true

module StoryTypes
  module Iterations
    class ExportTask < StoryTypesTask
      def perform(iteration_id, account_id, url = nil)
        iteration = StoryTypeIteration.find(iteration_id)
        account = Account.find(account_id)
        status = true
        message = 'Success. Make sure that all stories are exported'
        story_type = iteration.story_type
        exe_ensure = true

        story_type.sidekiq_break.update!(cancel: false)

        if opportunities_attached?(story_type, iteration)
          threads_count = (iteration.stories.count / 75_000.0).ceil + 1
          threads_count = threads_count > 20 ? 20 : threads_count

          iteration.update!(last_export_batch_size: nil)

          loop do
            Samples[PL_TARGET].export!(iteration, threads_count)

            last_export_batch = iteration.reload.last_export_batch_size.zero?
            break if last_export_batch
          end

          exp_st = ExportedStoryType.find_or_initialize_by(iteration: iteration)
          exp_st.story_type = story_type
          exp_st.first_export = iteration.name.eql?('Initial')
          exp_st.developer = account
          exp_st.count_samples = iteration.stories.count

          if exp_st.new_record?
            story_type.update!(last_export: DateTime.now, current_account: account)

            week_start = Date.today - (Date.today.wday - 1)
            week_end = week_start + 6

            exp_st.week = Week.find_or_create_by!(
              begin: week_start,
              end: week_end
            )
            exp_st.date_export = Date.today
          end

          exp_st.save!

          Rake::Task['story_type:setup:set_max_time_frame'].execute({ story_type_id: story_type.id })

          note = MiniLokiC::Formatize::Numbers.to_text(exp_st.count_samples).capitalize
          record_to_change_history(story_type, 'exported to pipeline', note, account)

          if story_type.iterations.last.eql?(iteration)
            if story_type.updates?
              story_type.reminder.update!(updates_confirmed: false, has_updates: false, current_account: account)
            end

            unless story_type.reload.status.name.in?(['canceled', 'blocked', 'on cron', 'exported'])
              story_type.update!(
                status: Status.find_by(name: 'exported'),
                last_status_changed_at: Time.now,
                current_account: account
              )
            end

            if Rails.env.production? && url && !iteration.name.match?(/CT\d{8}/)
              send_report_to_editors_slack(iteration, url)
            end
          end
        else
          status = nil
          exe_ensure = false
        end

        if story_type.sidekiq_break.cancel
          status = nil
          message = 'Canceled'
        end
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        iteration.reload.update!(export: status)

        if exe_ensure
          story_type.sidekiq_break.update!(cancel: false)
          send_to_action_cable(story_type, :export, message)
          SlackIterationNotificationTask.new.perform(iteration.id, 'export', message)
        end
      end


    end
  end
end
