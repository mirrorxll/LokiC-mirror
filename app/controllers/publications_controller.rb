# frozen_string_literal: true

class PublicationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :developer?
  before_action :find_client_publication_tag

  def include
    @publication = Publication.find(params[:id])
    render_400 && return if @story_type.clients_publications_tags.find_by(client: @client_publication_tag.client, publication: @publication).present?

    @client_publication_tag.update(publication: @publication, tag: nil)
  end

  def exclude
    render_400 && return unless @client_publication_tag.publication.present?

    @client_publication_tag.update(publication: nil, tag: nil)
  end

  private

  def find_client_publication_tag
    @client_publication_tag = StoryTypeClientPublicationTag.find(params[:client_publication_tag])
  end
end
