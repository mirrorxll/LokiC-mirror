# frozen_string_literal: true

class TableLocationsController < ApplicationController
  def new
    @model = Object.const_get(params[:model]).find(params[:model_id])
  end
end
