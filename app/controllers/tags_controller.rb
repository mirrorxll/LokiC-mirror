# frozen_string_literal: true

class TagsController < ApplicationController # :nodoc:
  before_action :render_400, if: :developer?
  before_action :find_story_type_client
  before_action :find_tag, only: :include

  def include
    render_400 && return if @story_type_client_tag.tag.present?

    @story_type_client_tag.update(tag: @tag)
  end

  def exclude
    render_400 && return unless @story_type_client_tag.tag.present?

    @story_type_client_tag.update(tag: nil)
  end

  private

  def find_story_type_client
    @story_type_client_tag =
      @story_type.client_tags.find_by(client_id: params[:client_id])
  end

  def find_tag
    @tag = Tag.find(params[:id])
  end
end
