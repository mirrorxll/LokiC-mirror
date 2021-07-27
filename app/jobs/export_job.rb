# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account, url = nil)
    status = true
    message = 'Success. Make sure that all stories are exported'
    story_type = iteration.story_type
    old_status = story_type.status.name
    threads_count = (iteration.samples.count / 75_000.0).ceil + 1
    threads_count = threads_count > 20 ? 20 : threads_count

    iteration.update!(last_export_batch_size: nil)

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          Samples[PL_TARGET].export!(iteration, threads_count)
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

      last_export_batch = iteration.reload.last_export_batch_size.zero?
      break if last_export_batch
    end

    exp_st = ExportedStoryType.find_or_initialize_by(iteration: iteration)
    exp_st.story_type = story_type
    exp_st.developer = story_type.developer
    exp_st.first_export = iteration.name.eql?('Initial')
    exp_st.count_samples = iteration.samples.count

    if exp_st.new_record?
      story_type.update(last_export: DateTime.now)

      exp_st.week = Week.where(begin: Date.today - (Date.today.wday - 1)).first
      exp_st.date_export = Date.today
    end

    exp_st.save!

    Process.wait(
      fork do
        body = MiniLokiC::Formatize::Numbers.to_text(exp_st.count_samples).capitalize
        record_to_change_history(story_type, 'exported to pipeline', body, account)

        if story_type.iterations.last.eql?(iteration)
          if story_type.updates?
            story_type.reminder.update_columns(
              updates_confirmed: nil, has_updates: false
            )
          end

          unless story_type.reload.status.name.in?(['canceled', 'blocked', 'on cron', 'exported'])
            story_type.update(status: Status.find_by(name: 'exported'), last_status_changed_at: Time.now)
            body = "#{old_status} -> exported"
            record_to_change_history(story_type, 'progress status changed', body, account)
          end

          if Rails.env.production? && url && !iteration.name.match?(/CT\d{8}/)
            send_report_to_editors_slack(iteration, url)
          end
        end
      end
    )

    true
  rescue StandardError => e
    status = nil
    message = e.message
  ensure
    iteration.reload.update(export: status)
    send_to_action_cable(iteration, :export, message)
    send_to_dev_slack(iteration, 'EXPORT', message)
  end
end
