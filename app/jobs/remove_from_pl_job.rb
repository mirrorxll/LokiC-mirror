# frozen_string_literal: true

class RemoveFromPlJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account)
    message = 'Success'
    story_type = iteration.story_type

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          Samples[PL_TARGET].remove!(iteration)
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

      break if iteration.samples.reload.exported.count.zero?
    end

    Process.wait(
      fork do
        iteration.exported&.destroy
        iteration.production_removals.last.update(status: true)

        body = MiniLokiC::Formatize::Numbers.to_text(iteration.samples.ready_to_export.count)
        record_to_change_history(story_type, 'removed from pipeline', body, account)

        old_status = story_type.status.name
        last_iteration = story_type.reload.iterations.last.eql?(iteration)
        changeable_status = !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])

        if !old_status.eql?('in progress') && last_iteration && changeable_status
          story_type.update(status: Status.find_by(name: 'in progress'), last_status_changed_at: Time.now)
          body = "#{old_status} -> in progress"
          record_to_change_history(story_type, 'progress status changed', body, account)
        end
      end
    )
  rescue StandardError => e
    message = e.message
  ensure
    iteration.update!(removing_from_pl: false)
    send_to_action_cable(iteration, :export, message)
    send_to_dev_slack(iteration, 'REMOVE FROM PL', message)
  end
end
