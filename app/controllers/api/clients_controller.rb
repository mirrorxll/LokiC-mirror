# frozen_string_literal: true

module Api
  class ClientsController < ApiController
    def visible
      visible = Client.where(hidden: false).order(:name)

      render json: { visible: visible }
    end

    def publications
      pub_names = ['all local publications', 'all statewide publications', 'all publications']
      publications = Publication.where(name: pub_names) + Client.find(params[:client_id]).publications.order(:name)

      render json: { attached: publications }
    end

    def tags
      tags = Client.find(params[:client_id]).tags.order(:name)

      render json: { attached: tags }
    end
  end
end
