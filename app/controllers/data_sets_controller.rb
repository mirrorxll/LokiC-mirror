# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  before_action :find_data_set, except: %i[index new create]

  def index
    @data_sets = DataSet.all

    @data_sets = @data_sets.where(data_set_filter_params) if params[:filter]
  end

  def show; end

  def new
    @data_set = DataSet.new
  end

  def create
    puts params
    @data_set =
      current_account.data_sets.build(data_set_params)

    if @data_set.save
      # redirect_to @data_set
    else
      # render :new
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
      :src_release_frequency_id,
      :src_scrape_frequency_id,
      :name,
      :src_address,
      :src_explaining_data,
      :src_release_frequency_manual,
      :src_scrape_frequency_manual,
      :cron_scraping,
      :location,
      :evaluation_document,
      :evaluated,
      :evaluated_at,
      :gather_task,
      :scrape_developer,
      :comment
    )
  end
end
