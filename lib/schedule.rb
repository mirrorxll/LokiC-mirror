# frozen_string_literal: true

require_relative 'schedule/old_scheduler'

module Schedule
  include Schedule::OldScheduler
  include Schedule::BackdateScheduler
  include Schedule::AutoScheduler
end
