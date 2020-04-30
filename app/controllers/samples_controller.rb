# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update destroy]

  def index
    @samples = @story_type.samples
  end

  def show; end

  def create
    params = samples_params
    puts params
    # CreateSamplesJob.set(wait: 1.second).perform_later(params[:rows], column_names)
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def samples_params
    raw_params = params.require(:samples).permit(:rows, columns: {})
    column_ids = Table.transform_for_samples(raw_params[:columns])
    column_names = @story_type.staging_table.columns.ids_to_names(column_ids)

    { column_names: column_names, rows: raw_params[:rows] }
  end
end
