# frozen_string_literal: true

class ClientsController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_client

  def include
    if @story.clients.exists?(@client.id)
      render json: { error: 'Bad Request' }, status: 400 and return
    end

    @story.clients << @client
  end

  def exclude
    return unless @story.clients.exists?(@client.id)

    @story.clients.destroy @client
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_client
    @client = Client.find(params[:id])
  end
end
