# frozen_string_literal: true

module Api
  class MainAgencyOpportunitiesController < ApiController
    def index
      opportunities = MainAgency.find(params[:main_agency_id]).opportunities.order(:name)

      render json: opportunities
    end
  end
end
