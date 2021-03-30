# frozen_string_literal: true

class RemoveSamplesByLastIterationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration)
    sleep(20)
    message = 'Success. All samples have been removed'

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          iteration.samples.limit(10_000).destroy_all
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

      break if iteration.samples.reload.blank?
    end

    iteration.update(
      story_samples: nil, creation: nil,
      schedule: nil, schedule_args: nil,
      schedule_counts: nil
    )
  rescue StandardError => e
    message = e
  ensure
    iteration.update(purge_all_samples: nil)
    send_to_action_cable(iteration, :samples, message)
    send_to_slack(iteration, 'CREATION', message)
  end
end
