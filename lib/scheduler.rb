# frozen_string_literal: true

require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'scheduler/base.rb'
require_relative 'scheduler/backdate.rb'
require_relative 'scheduler/auto.rb'

module Scheduler
  include Scheduler::Base
  include Scheduler::Backdate
  include Scheduler::Auto

  def self.run(samples, params = {})
    return if !ENV['RAILS_ENV'] || samples.instance_variable_get(:@sampled)

    iteration = samples.instance_variable_get(:@iteration)
    SchedulerJob.set(wait: 2.seconds).perform_later(iteration, 'run_from_code', params)
    iteration.update(schedule: false)
  end
end
