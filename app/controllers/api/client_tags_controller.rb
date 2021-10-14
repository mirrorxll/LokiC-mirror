# frozen_string_literal: true

module Api
  class ClientTagsController < ApiController
    def index
      tags = Client.find(params[:client_id]).tags.order(:name)

      render json: tags
    end
  end
end
