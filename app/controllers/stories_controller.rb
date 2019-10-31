# frozen_string_literal: true

class StoriesController < ApplicationController # :nodoc:
  before_action :find_book, except: %i[index]

  def index
    @stories = Story.all
  end

  def show; end

  def new
    @story = Story.new
  end

  def create
    @story = Story.new(story_params)
  end

  def edit; end

  def update
    @story.update(story_params)
  end

  def destroy
    @story.destroy
  end

  private

  def find_book
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(
      :name, :headline, :body, :description, :frequency, :level,
      :desired_launch, :last_launch, :last_export, :deadline, :status,
      :blocked, :writer_id, :developer_id
    )
  end
end
