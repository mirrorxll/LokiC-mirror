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
    @data_set =
      current_account.data_sets.build(data_set_params)

    if @data_set.save
      new_data_set_notification
      redirect_to @data_set
    else
      render :new
    end
  end

  def edit; end

  def update
    render :edit unless @data_set.update(data_set_params)
  end

  def evaluate
    render_400 && return if @data_set.evaluated?

    @data_set.update(evaluated: true, evaluated_at: Time.now)
    eval_data_set_notification
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

  def new_data_set_notification
    message = "Added a new Data set. Details: #{data_set_url(@data_set)}"
    SlackNotificationJob.perform_later('notifications_test', message)
  end

  def eval_data_set_notification
    message = "The '#{@data_set.name}' data set was evaluated. We can start to "\
              "create templates. Details: #{data_set_url(@data_set)}"

    SlackNotificationJob.perform_later('notifications_test', message)
  end
end
