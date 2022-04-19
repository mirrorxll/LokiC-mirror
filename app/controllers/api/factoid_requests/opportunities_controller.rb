# frozen_string_literal: true

module Api
  module FactoidRequests
    class OpportunitiesController < FactoidRequestsController
      def index
        opportunities =
          Agency.find(opportunity_params[:agency_id])
                .opportunities.order(:name)
                .as_json(only: %i[id name])

        render json: opportunities
      end

      private

      def opportunity_params
        params.require(:factoid_request).permit(:agency_id)
      end
    end
  end
end
