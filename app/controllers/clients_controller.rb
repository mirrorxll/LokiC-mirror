# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_client

  def add
    @story.clients << @client unless @story.clients.exists?(@client.id)
  end

  def remove
    @story.clients.destroy @client if @story.clients.exists?(@client.id)
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_client
    @client = Client.find(params[:client_id])
  end
end
