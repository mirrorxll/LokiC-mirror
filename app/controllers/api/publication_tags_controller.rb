# frozen_string_literal: true

module Api
  class PublicationTagsController < ApiController
    include TagsHelper

    def index
      client = Client.find(params[:client_id])
      publication = Publication.find(params[:publication_id])
      tags = tags_for_publication(publication, client)

      render json: tags
    end
  end
end
