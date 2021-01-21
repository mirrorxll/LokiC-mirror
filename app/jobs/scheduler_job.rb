# frozen_string_literal: true

class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(story_type, type, options = {})
    status = nil
    message = 'SUCCESS'
    iteration = story_type.iteration

    rd, wr = IO.pipe

    Process.wait(
      fork do
        rd.close
        samples = iteration.samples

        case type
        when 'manual'
          Scheduler::Base.old_scheduler(samples, options)
        when 'backdate'
          Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        when 'auto'
          Scheduler::Auto.auto_scheduler(samples)
        end

      rescue StandardError => e
        wr.write %({"#{e.class}":"#{e.message}"})
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

    status = true unless iteration.reload.samples.where(published_at: nil).any?
  rescue StandardError => e
    status = nil
    message = e
  ensure
    iteration.update(schedule: status)
    send_to_action_cable(story_type, iteration, scheduler_msg: message)
    send_to_slack(story_type, "#{type}-scheduling", message)
  end

  private

  def backdate_params(options)
    options.each_with_object({}) do |(_key, schedule), hash|
      date = schedule[:date]
      hash[date] = schedule[:where]
    end
  end
end
