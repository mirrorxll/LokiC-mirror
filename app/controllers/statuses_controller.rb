# frozen_string_literal: true

class StatusesController < ApplicationController
  before_action :find_status

  def include
    render_400 && return if @story_type.iteration.statuses.exists?(@status.id)

    # @story_type.clients << @client
    # @client_tag = @story_type.client_tags.reload.find_by(client: @client)
    #
    # @story_type.iteration.statuses << update(status: @status)
  end

  def exclude
    # @story_type.update(status: Status.first)
  end

  private

  def find_iteration
    @iteration = @story_type.iteration
  end

  def find_status
    @status = Status.find(params[:id])
  end
end
