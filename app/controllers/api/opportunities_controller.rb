# frozen_string_literal: true

module Api
  class OpportunitiesController < ApiController
    def index
      opportunities =
        Agency.find(opportunity_params[:agency_id])
              .opportunities.order(:name)
              .as_json(only: %i[id name])

      render json: opportunities
    end

    private

    def opportunity_params
      params.permit(:agency_id)
    end
  end
end
