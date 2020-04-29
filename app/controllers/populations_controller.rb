# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
    render_400 && return unless @story_type.iteration.population.nil?

    args = population_params
    PopulationJob.set(wait: 1.second).perform_later(@story_type, args)
    @story_type.update_iteration(population: false, population_args: args)
  end

  def purge
    @story_type.staging_table.purge
    @story_type.update_iteration(population: nil)
  end

  private

  def population_params
    raw = params.require(:population).permit(:args)
    raw[:args]
  end
end
