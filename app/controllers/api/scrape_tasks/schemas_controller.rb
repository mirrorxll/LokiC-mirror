# frozen_string_literal: true

module Api
  module ScrapeTasks
    class SchemasController < ApiController
      def index
        schemas = Host.find(params[:host]).schemas.select(:id, :name)

        render json: { schemas: schemas }
      end
    end
  end
end
