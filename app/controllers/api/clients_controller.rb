# frozen_string_literal: true

module Api
  class ClientsController < ApiController
    def index
      clients = Client.where(hidden_for_story_type: false).select(:id, :name).order(:name)

      render json: clients
    end
  end
end
