# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  before_action :find_data_set, except: %i[index new create]
  skip_before_action :find_story_type

  def index
    @data_sets = DataSet.all

    if params[:filter]
      @data_sets = @data_sets.where(data_set_filter_params)
    end
  end

  def show
    @story_types = @data_set.story_types
  end

  def new
    @data_set = DataSet.new
  end

  def create
    @data_set = DataSet.new(data_set_params)

    if @data_set.save
      redirect_to @data_set
    else
      render :new
    end
  end

  def edit; end

  def update
    if @data_set.update(data_set_params)
      redirect_to @data_set
    else
      render :edit
    end
  end

  def destroy
    @data_set&.destroy
  end

  private

  def find_data_set
    @data_set = DataSet.find(params[:id])
  end

  def data_set_filter_params
    params.require(:filter).permit(:evaluated)
  end

  def data_set_params
    params.require(:data_set).permit(
      :source_name,
      :data_set_location,
      :data_set_evaluation_document,
      :evaluated,
      :scrape_developer_name,
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