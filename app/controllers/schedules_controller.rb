# frozen_string_literal: true

class SchedulesController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?

  def manual
    SchedulerJob.perform_later(@iteration, 'manual', manual_params)
    @iteration.update(schedule: false)
    render 'hide_section'
  end

  def backdate
    SchedulerJob.perform_later(@iteration, 'backdate', backdated_params)
    @iteration.update(schedule: false)
    render 'hide_section'
  end

  def auto
    SchedulerJob.perform_later(@iteration, 'auto')
    @iteration.update(schedule: false)
    render 'hide_section'
  end

  def purge
    @iteration.samples.update_all(published_at: nil, backdated: 0)
    @iteration.update(schedule: nil, schedule_args: nil)
    flash.now[:message] = 'scheduling purged'
  end

  def section
    message = update_section_params[:message]
    flash.now[:message] = update_section_params[:message] if message.present?
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
    params.require(:backdate).permit!
  end

  def update_section_params
    params.require(:section_update).permit(:message)
  end
end
