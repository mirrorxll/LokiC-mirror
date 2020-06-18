# frozen_string_literal: true

class SchedulesController < ApplicationController # :nodoc:
  def manual
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'manual', manual_params)
    @story_type.update_iteration(schedule: false)
  end

  def backdate
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'backdate', backdated_params)
    @story_type.update_iteration(schedule: false)
  end

  def auto
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'auto')
    @story_type.update_iteration(schedule: false)
  end

  def purge
    @story_type.iteration.samples.update_all(published_at: nil, backdated: 0)
    @story_type.update_iteration(schedule: nil, schedule_args: nil)
  end

  private

  def manual_params
    params.permit(
      :start_date,
      :limit,
      :total_days_till_end,
      :extra_args
    )
  end

  def backdated_params
    params.require(:backdate).permit!.to_hash
  end
end