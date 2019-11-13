# frozen_string_literal: true

class LevelsController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_level

  def include
    return if @story.levels.count.positive?

    @story.levels << @level
  end

  def exclude
    return unless @story.levels.exists?(@level.id)

    @story.levels.clear
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_level
    @level = Level.find(params[:id])
  end
end
