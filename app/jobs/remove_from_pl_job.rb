# frozen_string_literal: true

class RemoveFromPlJob < ApplicationJob
  queue_as :default

  def perform(iteration)
    message = 'Success'

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

      break if iteration.samples.where.not(pl_production_story_id: nil).count.zero?
    end

  rescue StandardError => e
    message = e.message
  ensure
    iteration.update(removing_from_pl: nil)
    send_to_action_cable(iteration, remove_from_pl_msg: message)
    send_to_slack(iteration, 'REMOVE FROM PL', message)
  end
end
