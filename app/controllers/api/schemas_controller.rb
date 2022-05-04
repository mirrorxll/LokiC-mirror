# frozen_string_literal: true

module Api
  class SchemasController < ApiController
    def index
      schemas = Host.find(params[:host_id]).schemas.select(:id, :name)

      render json: { schemas: schemas }
    end
  end
end
