# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  def execute
  end

  def purge
  end

  private

  def population_params
    params.require(:population).permit
  end
end
