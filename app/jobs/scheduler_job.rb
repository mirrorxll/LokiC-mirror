# frozen_string_literal: true

class SchedulerJob < ApplicationJob
  queue_as :story_type

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
          MiniLokiC::Creation::Scheduler::Base.run_schedule(samples, manual_params(options))
        when 'backdate'
          MiniLokiC::Creation::Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        when 'auto'
          MiniLokiC::Creation::Scheduler::Auto.run_auto(samples, auto_params(options))
        when 'run-from-code'
          MiniLokiC::Creation::Scheduler::FromCode.run_from_code(samples, options)
        end

        notes = "executed #{type} scheduler"
        record_to_change_history(iteration.story_type, 'scheduled', notes)

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

    if iteration.reload.samples.where(published_at: nil).none?
      status = true
    end
  rescue StandardError => e
    status = nil
    message = e
  ensure
    iteration.update(schedule: status)
    send_to_action_cable(iteration, :scheduler, message)
    send_to_dev_slack(iteration, "#{type.upcase}-SCHEDULING", message)
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
      raise 'Error name of time frame' if time_frame_ids.blank? && !schedule[:time_frame].blank?

      hash[date] = time_frame_ids
    end
  end

  def manual_params(options)
    options.each_with_object([]) do |(_key, schedule), array|
      array << schedule
    end
  end
end
