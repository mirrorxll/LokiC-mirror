# frozen_string_literal: true

class PurgeSamplesJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account)
    message = 'Success. samples have been removed'

    rd, wr = IO.pipe

    Process.wait(
      fork do
        rd.close

        iteration.stories.where(sampled: true).destroy_all
        iteration.auto_feedback_confirmations.destroy_all
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

  rescue StandardError => e
    message = e.message
  ensure
    iteration.update!(samples_creation: nil, current_account: account)
    send_to_action_cable(iteration, :samples, message)
  end
end
