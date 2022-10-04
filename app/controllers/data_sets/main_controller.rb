# frozen_string_literal: true

module DataSets
  class MainController < DataSetsController # :nodoc:
    before_action :find_data_set, except: %i[index create]
    after_action  :set_default_props, only: %i[update]
    after_action  :create_hidden_scrape_task, only: :create

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    before_action :access_to_show, only: :show
    before_action :data_sets_access, only: :show

    def index
      @tab_title = 'LokiC :: DataSets'

      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]).per(30) }
        end

        f.csv do
          send_data(
            @grid.to_csv,
            type: 'text/csv', disposition: 'inline',
            filename: "lokiC_data_sets_#{Time.now}.csv"
          )
        end
      end
    end

    def show
      @tab_title = "LokiC :: DataSet ##{@data_set.id} <#{@data_set.name}>"
      @story_types = @data_set.story_types.order(id: :desc)
      @factoid_types = @data_set.factoid_types.order(id: :desc)
      @content_developers = AccountRole.find_by(name: 'Content Developer').accounts
    end

    def create
      @data_set = current_account.data_sets.create(data_set_params)

      @data_set.scrape_task&.table_locations&.each do |table_loc|
        @data_set.table_locations.create(
          host: table_loc.host,
          schema: table_loc.schema,
          sql_table: table_loc.sql_table
        )
      end

      respond_to do |f|
        f.html { redirect_to @data_set }
        f.js   { render 'data_set_from_scrape_task' }
      end
    end

    def update
      @data_set.update(data_set_params)
      @data_set.general_comment.update(general_comment_params)

      redirect_to @data_set
    end

    def destroy
      @data_set&.destroy
    end

    def properties; end

    private

    def grid_lists
      statuses      = Status.data_set_statuses
      allowed_grids = current_account.ordered_lists.where(branch_name: 'data_sets').order(:position)
      @lists        = HashWithIndifferentAccess.new

      allowed_grids.each do |grid|
        @lists[grid.grid_name] = { status: statuses }

        @lists[grid.grid_name].merge!(sheriff: current_account)                 if grid.grid_name.eql?('assigned')
        @lists[grid.grid_name].merge!(account: current_account)                 if grid.grid_name.eql?('created')
        @lists[grid.grid_name].merge!(responsible_editor: current_account)      if grid.grid_name.eql?('responsible')
        @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived')) if grid.grid_name.eql?('archived')
      end
    end

    def current_list
      keys = @lists.keys
      @current_list =
        if keys.include?(params[:list])
          params[:list]
        else
          first_grid = current_account.ordered_lists.first_grid('data_sets')
          (current_account.manager? || current_account.content_manager?) && @lists['all'] ? 'all' : first_grid
        end
    end

    def generate_grid
      return unless @current_list

      @grid = DataSetsGrid.new(params[:data_sets_grid]) do |scope|
        scope.where(@lists[@current_list])
      end
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      return if @lists['assigned'] && @data_set.sheriff.eql?(current_account)
      return if @lists['responsible'] && @data_set.responsible_editor.eql?(current_account)
      return if @lists['created'] && @data_set.account.eql?(current_account)
      return if @lists['all'] && @data_set.status != archived
      return if @lists['archived'] && @data_set.status.eql?(archived)

      flash[:error] = { data_set: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def data_sets_access
      card = current_account.cards.find_by(branch: Branch.find_by(name: 'data_sets'))
      @data_sets_permissions = card.access_level.permissions if card.enabled
    end

    def data_set_params
      params.require(:data_set).permit(
        :name, :slack_channel, :state_id, :category_id
      )
    end

    def general_comment_params
      params.require(:general_comment).permit(:body)
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
