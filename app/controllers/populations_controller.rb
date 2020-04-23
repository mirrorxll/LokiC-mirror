# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
    PopulationJob.perform_later(@story_type, population_params)
  end

  def purge
  end

  private

  def population_params
    raw = params.require(:population).permit(:options)
    raw[:options]
  end
end
