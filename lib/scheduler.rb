# frozen_string_literal: true

require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'scheduler/base.rb'
require_relative 'scheduler/backdate.rb'
require_relative 'scheduler/auto.rb'

module Scheduler
  include Scheduler::Base
  include Scheduler::Backdate
  include Scheduler::Auto

  def self.run(staging_table, options, scheduling_rules)
    return if options[:sampled] || !Table.all_created_by_last_iteration?(staging_table)

    options[:iteration].update(schedule: false)
    SchedulerJob.perform_now(options[:iteration], 'run-from-code', scheduling_rules)
  end
end
