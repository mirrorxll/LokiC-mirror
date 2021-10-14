# frozen_string_literal: true

module StoryTypes
  class ExceptedPublicationsController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :developer?
    before_action :find_publication

    def include
      excepted =
        @story_type.excepted_publications.find_by(publication: @publication)
      render_403 && return if excepted

      @excepted_publication = @story_type.excepted_publications.create!(
        client: @client,
        publication: @publication
      )
    end

    def exclude; end

    private

    def find_client
      @client = Client.find(params[:client_id])
    end

    def find_publication
      @publication = Publication.find(params[:publication_id])
    end
  end
end
