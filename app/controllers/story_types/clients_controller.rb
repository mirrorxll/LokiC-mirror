# frozen_string_literal: true

module StoryTypes
  class ClientsController < StoryTypesController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration

    before_action :find_client
    before_action :all_local_publications, only: :include

    def include
      render_403 && return if @story_type.clients_publications_tags.find_by(
        client: @client,
        publication: [nil, @all_local_publications]
      )

      @client_publication_tag =
        @story_type.clients_publications_tags.create!(
          client: @client,
          publication: @all_local_publications
        )
    end

    def exclude
      @client_publication_tag = StoryTypeClientPublicationTag.find(params[:client_publication_tag])
      @client_publication_tag.destroy
    end

    private

    def find_client
      @client = Client.find(params[:id])
    end

    def all_local_publications
      @all_local_publications = Publication.find_by(name: 'all local publications')
    end
  end
end
