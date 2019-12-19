# frozen_string_literal: true

class StoriesController < ApplicationController # :nodoc:
  before_action :find_story, except: %i[index new create]

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
    @story.writer = current_user

    if @story.save
      redirect_to story_path(@story)
    else
      render :new
    end
  end

  def edit; end

  def update
    @story.update!(story_params)
  end

  def dates
    @story.update!(dates_params)
  end

  def dev_status
    @story.update!(dev_status__params)
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
      :name, :body, :description, :desired_launch, :last_launch,
      :last_export, :deadline, :status, :blocked, :writer_id, :developer_id
    )
  end

  def filter_params
    params.slice(
      :writer, :developer, :client, :level, :frequency, :status
    )
  end

  def dates_params
    params.require(:story).permit(
      :deadline, :deadline, :desired_launch,
      :last_launch, :last_export
    )
  end

  def dev_status__params
    params.require(:story).permit(:dev_status)
  end
end
