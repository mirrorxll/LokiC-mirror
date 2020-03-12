# frozen_string_literal: true

class TagsController < ApplicationController # :nodoc:
  before_action :find_tag

  def include
    render_400 && return if @story_type.tags.exists?(@tag.id)

    @story_type.tags << @tag
  end

  def exclude
    render_400 && return unless @story_type.tags.exists?(@tag.id)

    @story_type.tags.destroy(@tag)
  end

  private

  def find_tag
    @tag = Tag.find(params[:id])
  end
end
