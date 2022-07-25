# frozen_string_literal: true

module DataSets
  class MainController < DataSetsController # :nodoc:
    before_action :find_data_set, except: %i[index create]
    after_action  :set_default_props, only: %i[create update]
    after_action  :create_hidden_scrape_task, only: :create

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index
    before_action :find_data_set, except: %i[index create]

    def index
      @tab_title = 'LokiC :: DataSets'
      @data_set = DataSet.new
    end

    def show
      @tab_title = "LokiC :: DataSet ##{@data_set.id} <#{@data_set.name}>"
      @story_types = @data_set.story_types.order(id: :desc)
      @factoid_types = @data_set.factoid_types.order(id: :desc)
    end

    def create
      @data_set = current_account.data_sets.create!(data_set_params)

      @data_set.scrape_task&.table_locations&.each do |table_loc|
        @data_set.table_locations.create!(
          host: table_loc&.host,
          schema: table_loc&.schema,
          table_name: table_loc&.table_name
        )
      end

      respond_to do |f|
        f.html { redirect_to @data_set }
        f.js   { render 'data_set_from_scrape_task' }
      end
    end

    def edit; end

    def update
      redirect_to @data_set if @data_set.update!(data_set_params)
    end

    def destroy
      @data_set&.destroy
    end

    def properties; end

    private

    def grid_lists
      @lists = HashWithIndifferentAccess.new

      @lists['all'] = {}     if @permissions['grid']['all']
      # @lists['archived'] = { archived: true } if @permissions['grid']['archived']
    end

    def current_list
      keys = @lists.keys
      @current_list = keys.include?(params[:list]) ? params[:list] : keys.first
    end

    def generate_grid
      return unless @current_list

      @grid = DataSetsGrid.new(params[:data_sets_grid] || @lists[@current_list])

      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end


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

      DataSetDefaultProps.setup!(@data_set, default_props_params)
    end

    def create_hidden_scrape_task
      create = params[:scrape_task]&.fetch(:create_hidden).to_i
      return if create.zero?

      scrape_task = ScrapeTask.create!(name: @data_set.name, creator: current_account, hidden: true)
      @data_set.update!(scrape_task: scrape_task)
    end
  end
end
