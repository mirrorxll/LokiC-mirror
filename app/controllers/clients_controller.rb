# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  skip_before_action :set_iteration

  before_action :render_403, if: :developer?
  before_action :find_client
  before_action :all_local_publications, only: :include

  def include
    render_403 && return unless @story_type.clients_publications_tags.find_by(client: @client, publication: [nil, all_local_publications]).nil?

    StoryTypeClientPublicationTag.create(story_type: @story_type, client: @client, publication: all_local_publications)
    @client_publication_tag = @story_type.clients_publications_tags.find_by(client: @client, publication: all_local_publications)
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
    @all_publications = Publication.find_by(name: 'all local publications')
  end
end
