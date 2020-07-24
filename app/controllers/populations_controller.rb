# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?

  def create
    render_400 && return unless @story_type.iteration.population.nil?

    args = population_params[:args]
    PopulationJob.set(wait: 2.second).perform_later(@story_type, args)
    @story_type.update_iteration(population: false, population_args: args)
  end

  def destroy
    # @story_type.staging_table.purge
    @story_type.update_iteration(population: nil)
  end

  private

  def population_params
    params.require(:population).permit(:args)
  end
end
