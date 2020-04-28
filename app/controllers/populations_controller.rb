# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
    if @story_type.iteration.population.nil?
      @story_type.update_iteration(population: false)
      jid = PopulationJob.perform_later(@story_type, population_params)
      @story_type.update_iteration(population_jid: jid)
    end
  end

  def purge
  end

  private

  def population_params
    raw = params.require(:population).permit(:options)
    raw[:options]
  end
end
