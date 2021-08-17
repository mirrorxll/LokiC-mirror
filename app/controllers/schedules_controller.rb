# frozen_string_literal: true

class SchedulesController < ApplicationController # :nodoc:
  before_action :render_403, if: :editor?

  def manual
    @iteration.update!(schedule: false, current_account: current_account)
    SchedulerJob.perform_later(@iteration, :manual, manual_params, current_account)
    render 'hide_section'
  end

  def backdate
    @iteration.update!(schedule: false, current_account: current_account)
    SchedulerJob.perform_later(@iteration, :backdate, backdated_params, current_account)
    render 'hide_section'
  end

  def auto
    @iteration.update!(schedule: false, current_account: current_account)
    SchedulerJob.perform_later(@iteration, :auto, auto_params, current_account)
    render 'hide_section'
  end

  def purge
    @iteration.samples.update_all(published_at: nil, backdated: 0)
    @iteration.update!(schedule: nil, schedule_args: nil, current_account: current_account)
    flash.now[:message] = 'scheduling purged'
  end

  def show_form
    @type = type_params[:type]
  end

  private

  def manual_params
    params.require(:manual).permit!
  end

  def backdated_params
    params.require(:backdate).permit!
  end

  def type_params
    params.permit(:type, :story_type_id, :iteration_id)
  end

  def auto_params
    params[:auto].blank? ? {} : params.require(:auto).permit!
  end

  def update_section_params
    params.require(:section_update).permit(:message)
  end
end
