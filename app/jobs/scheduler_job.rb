class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(story_type, type, options = {})
    samples = story_type.iteration.samples
    status = true

    message =
      case type.to_sym
      when :manual
        Scheduler::Base.old_scheduler(samples, options)
        'manual scheduling success'
      when :backdate
        Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        'backdate scheduling success'
      when :auto
        Scheduler::Auto.auto_scheduler(samples)
        'auto scheduling success'
      end
    status = false if story_type.iterations.last.samples.where(published_at: nil).any?

  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(schedule: status)
    send_to_action_cable(story_type, scheduler_message: status)
    send_to_slack(story_type, message)
  end

  private

  def backdate_params(options)
    params = {}
    options.each do |_key, schedule|
      date = schedule['date']
      params[date] = schedule['args']
    end
    params
  end
end
