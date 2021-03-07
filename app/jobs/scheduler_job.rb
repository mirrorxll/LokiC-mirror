# frozen_string_literal: true

class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(iteration, type, options = {})
    status = nil
    message = 'Success'

    rd, wr = IO.pipe

    Process.wait(
      fork do
        rd.close
        samples = iteration.samples

        case type
        when 'manual'
          Scheduler::Base.run_schedule(samples, manual_params(options))
        when 'backdate'
          Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        when 'auto'
          Scheduler::Auto.run_auto(samples, auto_params(options))
        when 'run-from-code'
          Scheduler::FromCode.run_from_code(samples, options)
        end

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

    status = true unless iteration.reload.samples.where(published_at: nil).any?
  rescue StandardError => e
    status = nil
    message = e
  ensure
    iteration.update(schedule: status)
    send_to_action_cable(iteration, scheduler_msg: message)
    send_to_slack(iteration, "#{type.upcase}-SCHEDULING", message)
  end

  private

  def backdate_params(options)
    options.each_with_object({}) do |(_key, schedule), hash|
      date = schedule[:date]
      hash[date] = schedule[:where]
    end
  end

  def auto_params(options)
    options.each_with_object({}) do |(_key, schedule), hash|
      date = schedule[:date]
      time_frame_ids = TimeFrame.where(frame: schedule[:time_frame]).ids
      hash[date] = time_frame_ids
    end
  end

  def manual_params(options)
    options.each_with_object([]) do |(_key, schedule), array|
      array << schedule
    end
  end
end
