# frozen_string_literal: true

class SchedulesController < ApplicationController # :nodoc:
  before_action :samples

  def manual
    render_400 && return unless @story_type.iteration.schedule.nil?

    SchedulerJob.set(wait: 2.seconds).perform_later(@samples, :manual, manual_params)
    @story_type.update_iteration(schedule: false)
  end

  def backdate
    render_400 && return unless @story_type.iteration.schedule.nil?

    SchedulerJob.set(wait: 2.seconds).perform_later(@samples, :backdate, backdated_params)
    @story_type.update_iteration(schedule: false)
  end

  def auto
    render_400 && return unless @story_type.iteration.schedule.nil?

    SchedulerJob.set(wait: 2.seconds).perform_later(@samples, :auto)
    @story_type.update_iteration(schedule: false)
  end

  def purge
    @samples.update_all(published_at: nil, backdated: 0)
    @story_type.update_iteration(schedule: nil, schedule_args: nil)
  end

  private

  def samples
    @samples = @story_type.iteration.samples
  end

  def manual_params
    params.permit(
      :start_date,
      :limit,
      :total_days_till_end,
      :extra_args
    )
  end

  def backdated_params
    params.permit(:dated, :args)
  end
end