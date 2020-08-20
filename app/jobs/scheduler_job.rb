class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(story_type, type, options = {})
    # samples = story_type.iteration.samples
    status = true

    message =
      case type
      when 'manual'
        Scheduler::Base.old_scheduler(samples, options)
        'manual scheduling success'
      when 'backdate'
        Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
        'backdate scheduling success'
      when 'auto'
        Scheduler::Auto.auto_scheduler(samples)
        'auto scheduling success'
      end
    status = false if story_type.iteration.samples.where(published_at: nil).any?

  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(schedule: status)
    send_to_action_cable(story_type, scheduler_msg: message)
    send_to_slack(story_type, message)
  end

  private

  def backdate_params(options)
    options.each_with_object({}) do |(_key, schedule), hash|
      date = schedule[:date]
      hash[date] = schedule[:where]
    end
  end
end
