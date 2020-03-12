# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  before_action :find_client

  def include
    render_400 && return if @story_type.clients.exists?(@client.id)

    @story_type.clients << @client
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
