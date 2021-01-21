# frozen_string_literal: true

class RemoveFromPlJob < ApplicationJob
  queue_as :default

  def perform(iteration)
    Process.wait(
      fork do
        message = 'SUCCESS'

        pl = Pipeline[:production]
        semaphore = Mutex.new
        samples = iteration.samples.where.not(
          "pl_#{PL_TARGET}_lead_id" => nil, "pl_#{PL_TARGET}_story_id" => nil
        )

        samples.find_in_batches(batch_size: 5_000) do |batch|
          samples = batch.to_a

          threads = Array.new(5) do
            Thread.new do
              loop do
                smpl = semaphore.synchronize { samples.pop }
                break if smpl.nil?

                pl.delete_lead(smpl[:pl_production_lead_id])
                smpl.update("pl_#{PL_TARGET}_lead_id" => nil, "pl_#{PL_TARGET}_story_id" => nil)
              end
            end
          end

          threads.each(&:join)
        end

        iteration.update(export: nil)
      rescue StandardError => e
        message = e.message
      ensure
        iteration.update(removing_from_pl: false)

        send_to_action_cable(iteration.story_type, iteration, remove_from_pl_msg: true)
        send_to_slack(iteration.story_type, 'remove from PL', message)
      end
    )
  end
end
