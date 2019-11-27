# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def run_code
    LokiC::Story::Population.new(@story).run #(population_params)
  end

  def purge_table
    LokiC::Story::Population.new(@story.id).purge(population_params)
  end

  private

  def population_params
    params.require(:population).permit
  end
end
