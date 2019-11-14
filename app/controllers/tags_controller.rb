# frozen_string_literal: true

class TagsController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_tag

  def include
    render_400 && return if @story.tags.exists?(@tag.id)

    @story.tags << @tag
  end

  def exclude
    render_400 && return unless @story.tags.exists?(@tag.id)

    @story.tags.destroy(@tag)
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_tag
    @tag = Tag.find(params[:id])
  end
end
