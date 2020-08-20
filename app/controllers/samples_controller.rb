# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def show
    @tab_title = @sample.headline

    respond_to do |format|
      format.html { render 'show' }
      format.js { render 'to_tab' }
    end
  end

  def create_and_generate_auto_feedback
    SamplesAndAutoFeedbackJob.set(wait: 2.second).perform_later(@story_type, samples_params)
    @story_type.update_iteration(story_samples: false)
    render 'creations/create'
  end

  def section
    flash.now[:message] = update_section_params[:message]
  end

  def purge_sampled
    @story_type.iteration.samples.where(sampled: true).destroy_all
    @story_type.iteration.auto_feedback_confirmations.destroy_all
    @story_type.staging_table.samples_set_not_created
    @story_type.update_iteration(story_samples: nil)
    flash.now[:message] = 'Samples deleted.'
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def update_section_params
    params.require(:section_update).permit(:message)
  end

  def samples_params
    params.require(:samples).permit(:row_ids, columns: {})
  end
end
