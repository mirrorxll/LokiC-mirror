# frozen_string_literal: true

module StoryTypes
  class ExceptedPublicationsController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration

    before_action :find_client, only: :include
    before_action :find_publication
    before_action :find_excepted_publication

    def include
      render_403 && return if @excepted_publication

      @excepted_publication =
        @story_type.excepted_publications.create!(
          client: @client,
          publication: @publication
        )
    end

    def exclude
      render_403 && return unless @excepted_publication

      @excepted_publication.destroy
    end

    private

    def find_client
      @client = Client.find(params[:client_id])
    end

    def find_publication
      @publication = Publication.find(params[:publication_id] || params[:id])
    end

    def find_excepted_publication
      @excepted_publication = @story_type.excepted_publications.find_by(publication: @publication)
    end
  end
end
