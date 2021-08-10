# frozen_string_literal: true

module Api
  class ClientsController < ApiController
    def visible
      visible = Client.where(hidden: false).order(:name)

      render json: { visible: visible }
    end

    def publications
      publications = Publication.where(name: ['all local publications', 'all statewide publications', 'all publications']) +
        Client.find(params[:client_id]).publications.order(:name)

      render json: { attached: publications }
    end

    def tags
      client = Client.find(params[:client_id])
        tags_for_publication
      tags = Client.find(params[:client_id]).tags.order(:name)

      render json: { attached: tags }
    end
  end
end
