# frozen_string_literal: true

class DataLocationsController < ApplicationController # :nodoc:
  before_action :find_data_location, except: %i[index new create]
  before_action :find_story, only: %i[include exclude]

  def index
    @data_locations = DataLocation.all
  end

  def show; end

  def new
    @data_location = DataLocation.new
  end

  def create
    @data_location = DataLocation.new(data_location_params)

    if @data_location.save
      redirect_to @data_location
    else
      render :new
    end
  end

  def edit; end

  def update
    if @data_location.update(data_location_params)
      redirect_to @data_location
    else
      render :edit
    end
  end

  def destroy
    @data_location.destroy
  end

  def include
    render_400 && return if @story.data_locations.exists?(@data_location.id)

    @story.data_locations << @data_location
  end

  def exclude
    render_400 && return unless @story.data_locations.exists?(@data_location.id)

    @story.data_locations.destroy(@data_location)
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_data_location
    @data_location = DataLocation.find(params[:id])
  end

  def data_location_params
    params.require(:data_location).permit(:name, :source, :dataset, :note)
  end
end
