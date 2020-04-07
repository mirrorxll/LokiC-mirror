# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  before_action :find_client

  def include
    if @client.nil? || @story_type.clients.exists?(@client.id)
      render_400 && return
    end

    @story_type.clients << @client
  end

  def exclude
    render_400 && return unless @story_type.clients.exists?(@client.id)

    @story_type.clients.destroy(@client)
  end

  private

  def find_client
    return if params[:id].empty?

    @client = Client.find(params[:id])
  end
end
