# frozen_string_literal: true

class SchedulerJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, type, options = {}, account = nil)
    status = nil
    message = 'Success'
    story_type = iteration.story_type
    account ||= story_type.developer

    rd, wr = IO.pipe

    Process.wait(
      fork do
        rd.close
        samples = iteration.samples

        case type
        when :manual
          MiniLokiC::Creation::Scheduler::Base.run_schedule(samples, manual_params(options))
        when :backdate
          MiniLokiC::Creation::Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        when :auto
          MiniLokiC::Creation::Scheduler::Auto.run_auto(samples, auto_params(options))
        when :run_from_code
          MiniLokiC::Creation::Scheduler::FromCode.run_from_code(samples, options)
        end

        record_to_change_history(story_type, 'scheduled', type, account)
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

    status = true if iteration.reload.samples.where(published_at: nil).none?

    true
  rescue StandardError => e
    status = nil
    message = e.message
  ensure
    iteration.update!(schedule: status)
    send_to_action_cable(iteration, :scheduler, message)
    SlackStoryTypeNotificationJob.perform_now(iteration, "#{type}-scheduling", message)
  end

  private

  def backdate_params(options)
    options.each_with_object({}) do |(_key, schedule), hash|
      time_frame = schedule[:time_frame]
      schedule[:end_date] = schedule[:begin_date] if schedule[:end_date].blank?
      hash[time_frame] = [schedule[:begin_date], schedule[:end_date]]
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
      time_frame_ids = TimeFrame.where(frame: schedule[:time_frame]).ids
      raise 'Error name of time frame' if time_frame_ids.blank? && !schedule[:time_frame].blank?
      schedule[:time_frame] = time_frame_ids
      array << schedule
    end
  end
end
