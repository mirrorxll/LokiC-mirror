# frozen_string_literal: true

require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'scheduler/base.rb'
require_relative 'scheduler/backdate.rb'
require_relative 'scheduler/auto.rb'

module Scheduler
  include Scheduler::Base
  include Scheduler::Backdate
  include Scheduler::Auto
end
