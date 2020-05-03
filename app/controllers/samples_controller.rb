# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update destroy]

  def index
    @samples = @story_type.samples
  end

  def show; end

  def create
    CreateSamplesJob.perform_later(@story_type, samples_params)
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def samples_params
    params.require(:samples).permit(:row_ids, columns: {})
  end
end
