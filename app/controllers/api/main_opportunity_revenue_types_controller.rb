# frozen_string_literal: true

module Api
  class MainOpportunityRevenueTypesController < ApiController
    def index
      revenue_types = MainOpportunity.find(params[:main_opportunity_id]).revenue_types

      render json: revenue_types
    end
  end
end
