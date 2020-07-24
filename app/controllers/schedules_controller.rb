# frozen_string_literal: true

class SchedulesController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?
  after_action :iteration_update, except: :purge

  def manual
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'manual', manual_params)
    @story_type.update_iteration(schedule: false)
    render 'hide_section'
  end

  def backdate
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'backdate', backdated_params)
    @story_type.update_iteration(schedule: false)
    render 'hide_section'
  end

  def auto
    SchedulerJob.set(wait: 2.seconds).perform_later(@story_type, 'auto')
    @story_type.update_iteration(schedule: false)
    render 'hide_section'
  end

  def purge
    @story_type.iteration.samples.update_all(published_at: nil, backdated: 0)
    @story_type.update_iteration(schedule: nil, schedule_args: nil)
  end

  def section; end

  private

  def iteration_update

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
    params.require(:backdate).permit!.to_hash
  end
end
