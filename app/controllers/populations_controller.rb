# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
    @story.staging_table&.execute_population({})
  end

  def purge
    @story.staging_table.purge_last_population
  end

  private

  def population_params
    params.require(:population).permit
  end
end
