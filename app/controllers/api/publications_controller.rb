# frozen_string_literal: true

module Api
  class PublicationsController < ApiController
    include TagsHelper

    def tags
      client = Client.find(params[:client_id])
      publication = Publication.find(params[:publication_id])

      tags = tags_for_publication(publication, client)

      render json: { attached: tags }
    end
  end
end
