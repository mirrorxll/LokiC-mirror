# frozen_string_literal: true

class RemoveFromPlJob < ApplicationJob
  queue_as :story_type

  def perform(iteration)
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

    iteration.exported&.destroy
    iteration.production_removals.last.update(status: true)

    notes = "story(ies) related to `#{iteration.id}--#{iteration.name}` iteration removed from Pipeline"
    record_to_change_history(story_type, 'removed from production', notes)
  rescue StandardError => e
    message = e.message
  ensure
    all_removed = iteration.samples.exported.count.zero?
    last_iteration = story_type.reload.iterations.last.eql?(iteration)
    changeable_status = !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])

    if all_removed && last_iteration && changeable_status
      story_type.update(status: Status.find_by(name: 'in progress'), last_status_changed_at: DateTime.now)
      notes = "progress status changed to 'in progress'"
      record_to_change_history(story_type, 'progress status changed', notes)
    end

    iteration.update(removing_from_pl: false)
    send_to_action_cable(iteration, :export, message)
    send_to_dev_slack(iteration, 'REMOVE FROM PL', message)
  end
end
