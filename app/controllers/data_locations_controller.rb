# frozen_string_literal: true

class DataLocationsController < ApplicationController # :nodoc:
  before_action :find_data_location, except: %i[index new create]
  skip_before_action :find_story, except: %i[include exclude]

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

  def find_data_location
    @data_location = DataLocation.find(params[:id])
  end

  def data_location_params
    params.require(:data_location).permit(
      :source_name,
      :data_set_location,
      :data_set_evaluation_document,
      :scrape_dev_developer_name,
      :scrape_source,
      :scrape_frequency,
      :data_release_frequency,
      :cron_scraping,
      :scrape_developer_comments,
      :source_key_explaining_data,
      :gather_task
    )
  end
end
