# frozen_string_literal: true

class DataLocationsController < ApplicationController # :nodoc:
  before_action :find_data_location, except: %i[index new create]
  skip_before_action :find_story_type

  def index
    @data_locations = DataLocation.all

    if params[:filter]
      @data_locations = @data_locations.where(data_location_filter_params)
    end
  end

  def show
    @story_types = @data_location.story_types
  end

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
      SendNotificationToSlackJob.perform_async(
        channel: 'remainder_tool_test',
        text: '......',
        as_user: true
      )
      redirect_to @data_location
    else
      render :edit
    end
  end

  def destroy
    @data_location.destroy
  end

  private

  def find_data_location
    @data_location = DataLocation.find(params[:id])
  end

  def data_location_filter_params
    params.require(:filter).permit(:evaluated)
  end

  def data_location_params
    params.require(:data_location).permit(
      :source_name,
      :data_set_location,
      :data_set_evaluation_document,
      :evaluated,
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
