# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  private

  def find_story_type
    @story_type = StoryType.find(params[:story_type_id] || params[:id])
  end
end
