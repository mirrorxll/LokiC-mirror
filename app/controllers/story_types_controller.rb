# frozen_string_literal: true

class StoryTypesController < ApplicationController # :nodoc:
  before_action :find_story_type, except: %i[index new create]

  def index
    @story_types = StoryType.all

    filter_params.each do |key, value|
      @story_types = @story_types.public_send(key, value) if value.present?
    end
  end

  def show; end

  def new
    @story_type = StoryType.new
  end

  def create
    @story_type = StoryType.new(story_params)
    @story_type.writer = current_user

    if @story_type.save
      redirect_to story_type_path(@story_type)
    else
      render :new
    end
  end

  def edit; end

  def update
    @story_type.update!(story_type_params)
  end

  def dates
    @story_type.update!(dates_params)
  end

  def dev_status
    @story_type.update!(dev_status__params)
  end

  def destroy
    @story_type.destroy
  end

  private

  def find_story_type
    @story_type = StoryType.find(params[:id])
  end

  def story_type_params
    params.require(:story_type).permit(:name, :body, :description)
  end

  def filter_params
    params.slice(
      :writer, :developer, :client, :level, :frequency, :dev_status
    )
  end

  def dates_params
    params.require(:story_type).permit(
      :deadline, :deadline, :desired_launch,
      :last_launch, :last_export
    )
  end

  def dev_status__params
    params.require(:story_type).permit(:dev_status)
  end
end
