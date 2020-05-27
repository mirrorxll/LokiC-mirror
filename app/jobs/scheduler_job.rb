class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(samples, type, options = {})
    case type
    when :manual
      Schedule::OldScheduler.old_scheduler(samples, options)
    when :backdate
      Schedule::BackdateScheduler.backdate_scheduler(samples, options)
    when :auto
      Schedule::AutoScheduler.auto_scheduler(samples)
    end
  end
end
