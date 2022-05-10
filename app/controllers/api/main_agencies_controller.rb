# frozen_string_literal: true

module Api
  class MainAgenciesController < ApiController
    def index
      agencies = MainAgency.all.select(:id, :name).order(:name)

      render json: agencies
    end
  end
end
