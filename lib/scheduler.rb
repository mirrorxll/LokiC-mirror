# frozen_string_literal: true

module Scheduler
  def self.run(samples, params = {})
    return if !ENV['RAILS_ENV'] || samples.instance_variable_get(:@sampled)

    iteration = samples.instance_variable_get(:@iteration)
    SchedulerJob.set(wait: 2.seconds).perform_later(iteration, 'run_from_code', params)
    iteration.update(schedule: false)
  end
end
