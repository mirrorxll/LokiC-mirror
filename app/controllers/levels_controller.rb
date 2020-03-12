# frozen_string_literal: true

class LevelsController < ApplicationController # :nodoc:
  before_action :find_level

  def include
    render_400 && return if @story_type.levels.count.positive?

    @story_type.levels << @level
  end

  def exclude
    render_400 && return unless @story_type.levels.exists?(@level.id)

    @story_type.levels.clear
  end

  private

  def find_level
    @level = Level.find(params[:id])
  end
end
