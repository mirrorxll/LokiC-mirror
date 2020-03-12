# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
    PopulationJob.perform_later(@story_type.id)
  end

  def purge
    PurgeLastPopulationJob.perform_later(@story_type.id)
  end

  private

  def population_params
    params.require(:population).permit
  end
end
