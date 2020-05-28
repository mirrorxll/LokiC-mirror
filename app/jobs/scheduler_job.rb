class SchedulerJob < ApplicationJob
  queue_as :scheduler

  def perform(story_type, type, options = {})
    samples = story_type.iteration.samples

    case type.to_sym
    when :manual
      Schedule::OldScheduler.old_scheduler(samples, options)
    when :backdate
      params = {}
      options.each do |_key, schedule|
        date = schedule['date']
        params[date] = schedule['args']
      end

      Schedule::BackdateScheduler.backdate_scheduler(samples, params)
    when :auto
      Schedule::AutoScheduler.auto_scheduler(samples)
    end
  end
end
