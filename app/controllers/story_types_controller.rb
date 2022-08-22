# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  before_action -> { authorize!('story_types') }
  before_action -> { authorize!('data_sets', redirect: false) }

  before_action :find_story_type
  before_action :set_story_type_iteration

  private

  def find_story_type
    @story_type = StoryType.find(params[:story_type_id] || params[:id])
  end

  def set_story_type_iteration
    @iteration =
      if params[:iteration_id]
        StoryTypeIteration.find(params[:iteration_id])
      else
        @story_type.iteration
      end
  end
end
