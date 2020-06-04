# frozen_string_literal: true

class StatusesController < ApplicationController
  before_action :find_status

  def include
    @story_type.update(status: @status)
  end

  def exclude
    @story_type.update(status: Status.first)
  end

  private

  def find_status
    @status = Status.find(params[:id])
  end
end
