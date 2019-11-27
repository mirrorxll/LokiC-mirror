# frozen_string_literal: true

class LevelsController < ApplicationController # :nodoc:
  before_action :find_level

  def include
    render_400 && return if @story.levels.count.positive?

    @story.levels << @level
  end

  def exclude
    render_400 && return unless @story.levels.exists?(@level.id)

    @story.levels.clear
  end

  private

  def find_level
    @level = Level.find(params[:id])
  end
end
