# frozen_string_literal: true

class StoriesController < ApplicationController # :nodoc:
  before_action :find_story, except: %i[index]

  def index
    @stories = Story.all

    filter_params.each do |key, value|
      @stories = @stories.public_send(key, value) if value.present?
    end
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

  def find_story
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(
      :name, :headline, :body, :description, :desired_launch,
      :last_launch, :last_export, :deadline, :status, :blocked,
      :writer_id, :developer_id
    )
  end

  def filter_params
    params.slice(
      :writer, :developer, :client, :level, :frequency
    )
  end
end
