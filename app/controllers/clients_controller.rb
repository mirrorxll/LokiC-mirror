# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  skip_before_action :set_iteration

  before_action :render_400, if: :developer?
  before_action :find_client

  def include
    render_400 && return if @story_type.clients.exists?(@client.id)

    @story_type.clients << @client
    @client_tag = @story_type.client_tags.find_by(client: @client)
  end

  def exclude
    render_400 && return unless @story_type.clients.exists?(@client.id)

    @story_type.clients.destroy(@client)
  end

  private

  def find_client
    @client = Client.find(params[:id])
  end
end
