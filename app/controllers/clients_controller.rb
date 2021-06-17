# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  skip_before_action :set_iteration

  before_action :render_400, if: :developer?
  before_action :find_client

  def include
    render_400 && return unless @story_type.clients_publications_tags.find_by(client: @client, publication: [nil, Publication.find_by(name: 'all publications')]).nil?

    @story_type.clients << @client
    @client_publication_tag = @story_type.clients_publications_tags.find_by(client: @client, publication: Publication.find_by(name: 'all publications'))
  end

  def exclude
    @client_publication_tag = StoryTypeClientPublicationTag.find(params[:client_publication_tag])
    @client_publication_tag.destroy
  end

  private

  def find_client
    @client = Client.find(params[:id])
  end
end
