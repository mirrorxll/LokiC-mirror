# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_client

  def include
    render_400 && return if @story.clients.exists?(@client.id)

    @story.clients << @client
  end

  def exclude
    render_400 && return unless @story.clients.exists?(@client.id)

    @story.clients.destroy(@client)
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_client
    @client = Client.find(params[:id])
  end
end
