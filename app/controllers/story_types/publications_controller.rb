# frozen_string_literal: true

module StoryTypes
  class PublicationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :developer?
    before_action :find_publication
    before_action :find_client_publication_tag

    def include
      if @story_type.clients_publications_tags.find_by(client: @client_publication_tag.client, publication: @publication).present?
        render_403 && return
      end

      @client_publication_tag.update!(publication: @publication, tag: nil)
    end

    def exclude
      render_403 && return unless @client_publication_tag.publication.present?

      @client_publication_tag.update!(publication: nil, tag: nil)
    end

    private

    def find_publication
      @publication = Publication.find(params[:id])
    end

    def find_client_publication_tag
      @client_publication_tag = StoryTypeClientPublicationTag.find(params[:client_publication_tag])
    end
  end
end
