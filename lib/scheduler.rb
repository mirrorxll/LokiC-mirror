# frozen_string_literal: true

require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'scheduler/base.rb'
require_relative 'scheduler/backdate.rb'
require_relative 'scheduler/auto.rb'

module Scheduler
  include Scheduler::Base
  include Scheduler::Backdate
  include Scheduler::Auto

  def self.run(samples, params = {}, options = {})
    return if !ENV['RAILS_ENV'] && options[:sampled]

    story_type = samples.instance_variable_get(:@s_type)
    SchedulerJob.set(wait: 2.seconds).perform_later(story_type, 'manual', params)
    story_type.iteration.update(schedule: false)
  end

  def self.backdate(samples, params = {}, options = {})
    return if !ENV['RAILS_ENV'] && options[:sampled]

    story_type = samples.instance_variable_get(:@s_type)
    SchedulerJob.set(wait: 2.seconds).perform_later(story_type, 'manual', params)
  end
end
