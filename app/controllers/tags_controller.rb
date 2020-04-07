# frozen_string_literal: true

class TagsController < ApplicationController # :nodoc:
  before_action :find_tag, only: :include

  def include
    render_400 && return if @story_type.tag

    @story_type.update(tag: @tag)
  end

  def exclude
    render_400 && return unless @story_type.tag

    @story_type.update(tag: nil)
  end

  private

  def find_tag
    return if params[:id].empty?

    @tag = Tag.find(params[:id])
  end
end
