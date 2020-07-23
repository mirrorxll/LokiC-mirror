# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def show; end

  def create_and_generate_feedback
    SamplesAndFeedbackJob.set(wait: 2.second).perform_later(@story_type, samples_params)
    @story_type.update_iteration(story_samples: false)

    render 'creations/create'
  end

  def section; end

  def purge_sampled
    @story_type.iteration.samples.where(sampled: true).destroy_all
    @story_type.iteration.feedback_confirmations.destroy_all
    @story_type.staging_table.samples_set_not_created
    @story_type.update_iteration(story_samples: nil, story_sample_ids: nil)
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def samples_params
    params.require(:samples).permit(:row_ids, columns: {})
  end
end
