# frozen_string_literal: true

module Api
  class PublicationsController < ApiController
    def tags
      client = Client.find(params[:client_id])
      publication = Publication(params[:publication_id])

      tags = Client.find(params[:client_id]).tags.order(:name)

      render json: { attached: tags }
    end
  end
end
