# frozen_string_literal: true

module Api
  module V1
    module FactoidTypes
      class MainController < FactoidTypesController
        def index
          render json: FactoidType.all.map(&:name) if params[:names]
        end
      end
    end
  end
end
