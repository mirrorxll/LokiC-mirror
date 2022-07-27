# frozen_string_literal: true

module Api
  module V1
    class FactoidTypesController < ApiController
      private

      def find_factoid_type
        @factoid_type = FactoidType.find(params[:factoid_type_id] || params[:id])
      end
    end
  end
end

