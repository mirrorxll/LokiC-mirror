# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def index; end

  def show; end

  def create
    # render_400 && return unless @story_type.iteration.story_samples.nil?

    SamplesJob.set(wait: 5.second).perform_later(@story_type, samples_params)
    @story_type.update_iteration(story_samples: false)
  end

  def purge_sampled
    @story_type.iteration.samples.where(sampled: true).destroy_all
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
