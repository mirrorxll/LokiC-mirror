# frozen_string_literal: true

module Api
  class ClientsController < ApiController

    def visible
      visible = Client.where(hidden_for_story_type: false).order(:name)

      render json: { visible: visible }
    end

    def publications
      publications = Publication.where(name: ['all local publications', 'all publications','all statewide publications']).order(Arel.sql"name in ('all local publications') DESC, name DESC") +
        Client.find(params[:client_id]).publications.order(:name)

      render json: { attached: publications }
    end

    def tags
      tags = Client.find(params[:client_id]).tags.order(:name)

      render json: { attached: tags }
    end

    def local_publication
      render json: {  attached: Publication.find_by(name: 'all local publications').id }
    end
  end
end
