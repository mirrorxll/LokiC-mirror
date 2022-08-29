# frozen_string_literal: true

class SchemasController < ApplicationController
  def index
    schemas = Host.find(params[:host_id]).schemas.existing.select(:id, :name)

    render json: { schemas: schemas }
  end
end
