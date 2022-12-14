# frozen_string_literal: true

module StoryTypes
  class TagsController < StoryTypesController # :nodoc:
    before_action :find_client_publication_tag
    before_action :find_tag, only: :include

    def include
      render_403 && return if @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: @tag)
    end

    def exclude
      render_403 && return unless @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: nil)
    end

    private

    def find_client_publication_tag
      @client_publication_tag =
        @story_type.clients_publications_tags.find(params[:client_publication_tag])
    end

    def find_tag
      @tag = Tag.find(params[:id])
    end
  end
end
