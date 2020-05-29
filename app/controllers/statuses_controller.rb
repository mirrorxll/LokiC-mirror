# frozen_string_literal: true

class StatusesController < ApplicationController
  before_action :find_status
  before_action :find_statuses

  def include
    render_400 && return if @statuses.nil? || @statuses.exists?(@status.id)

    @statuses << @status
  end

  def exclude
    render_400 && return unless @statuses.exists?(@status.id)

    @statuses.destroy(@status)
  end

  private

  def find_status
    @status = Status.find(params[:id])
  end

  def find_statuses
    @statuses = @story_type.statuses
  end
end
