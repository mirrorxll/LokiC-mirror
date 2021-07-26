# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :render_403_developer, except: :properties, if: :developer?
  before_action :render_403_scraper, except: :properties, if: :scraper?
  before_action :find_data_set, except: %i[index create]
  after_action  :set_default_props, only: %i[create update]

  def index
    @tab_title = 'LokiC::Data Sets'
    @data_set = DataSet.new
    @data_sets_grid = DataSetsGrid.new(params[:data_sets_grid])
    respond_to do |f|
      f.html do
        @data_sets_grid.scope { |scope| scope.page(params[:page]).per(50) }
      end
      f.csv do
        send_data @data_sets_grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "LokiC_DataSets_#{Time.now}.csv"
      end
    end
  end

  def show
    @tab_title = @data_set.name
    @story_types = @data_set.story_types.order(id: :desc)

    story_type_filter_params.each do |key, value|
      @story_types = @story_types.where(key => value) if value.present?
    end
  end

  def create
    @data_set = current_account.data_sets.create!(data_set_params)

    respond_to do |f|
      f.html { redirect_to @data_set }
      f.js   { render 'data_set_from_scrape_task' }
    end
  end

  def edit; end

  def update
    redirect_to @data_set if @data_set.update(data_set_params)
  end

  def destroy
    @data_set&.destroy
  end

  def properties; end

  private

  def find_data_set
    @data_set = DataSet.find(params[:id])
  end

  def data_set_params
    params.require(:data_set).permit(
      :name, :location, :preparation_doc,
      :slack_channel, :sheriff_id, :comment,
      :state_id, :category_id, :scrape_task_id
    )
  end

  def default_props_params
    params.require(:default_props).permit(
      :photo_bucket_id, client_tag_ids: {}
    )
  end

  def set_default_props
    @data_set.data_set_photo_bucket&.delete
    @data_set.client_publication_tags.destroy_all

    DataSetDefaultProps.setup(@data_set, default_props_params)
  end

  def story_type_filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(
      :editor, :developer, :client, :frequency, :status
    )
  end
end
