# frozen_string_literal: true

module ScrapeTasks
  class MainController < ScrapeTasksController
    before_action :find_scrape_task, only: %i[show edit cancel_edit update]
    before_action :find_data_set,    only: %i[show edit cancel_edit]

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    before_action :access_to_show, only: :show
    before_action :data_sets_access, only: :show

    def index
      pp ' *** '*100
      @tab_title = 'LokiC :: ScrapeTasks'
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def show
      @tab_title = "LokiC :: ScrapeTask ##{@scrape_task.id} <#{@scrape_task.name}>"
    end

    def create
      @scrape_task = ScrapeTask.new(create_scrape_task_params)
      @scrape_task.creator = current_account

      if @scrape_task.save
        redirect_to @scrape_task
      else
        flash[:error] = @scrape_task.errors
      end
    end

    def update
      @scrape_task.datasource_comment.update!(datasource_comment_param)
      @scrape_task.scrape_ability_comment.update!(scrape_ability_comment_param)
      @scrape_task.general_comment.update!(general_comment_param)
      @scrape_task.update!(update_scrape_task_params)

      redirect_to @scrape_task
    end

    private

    def grid_lists
      statuses      = Status.scrape_task_statuses(created: true, done: true)
      allowed_grids = current_account.ordered_lists.where(branch_name: 'scrape_tasks').order(:position)
      @lists        = HashWithIndifferentAccess.new

      allowed_grids.each do |grid|
        @lists[grid.grid_name] = { status: statuses }

        @lists[grid.grid_name].merge!(creator: current_account) if grid.grid_name.eql?('created')
        @lists[grid.grid_name].merge!(scraper: current_account) if grid.grid_name.eql?('assigned')
        @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived')) if grid.grid_name.eql?('archived')
      end
    end

    def current_list
      pp ' <<< '*100
      keys = @lists.keys
      @current_list =
        if keys.include?(params[:list])
          params[:list]
        else
          first_grid = current_account.ordered_lists.first_grid('scrape_tasks')
          (current_account.manager? || current_account.scrape_manager?) && @lists['all'] ? 'all' : @current_list = first_grid
        end
      pp ' <<< '*100, @current_list
    end

    def generate_grid
      return unless @current_list

      @grid = ScrapeTasksGrid.new(params[:scrape_tasks_grid]) do |scope|
        scope.where(@lists[@current_list])
      end

      @grid.current_account = current_account
      @grid.current_list = @current_list
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      return if @lists['assigned'] && @scrape_task.scraper.eql?(current_account)
      return if @lists['created'] && @scrape_task.creator.eql?(current_account)
      return if @lists['all'] && @scrape_task.status != archived
      return if @lists['archived'] && @scrape_task.status.eql?(archived)

      flash[:error] = { scrape_tasks: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def data_sets_access
      card = current_account.cards.find_by(branch: Branch.find_by(name: 'data_sets'))
      @data_sets_permissions = card.access_level.permissions if card.enabled
    end

    def find_data_set
      @data_set = @scrape_task.data_set || DataSet.new
    end

    def create_scrape_task_params
      params.require(:scrape_task).permit(:name)
    end

    def update_scrape_task_params
      attrs =
        params.require(:scrape_task).permit(
          :name, :gather_task, :deadline,
          :state_id, :datasource_url, :scrapable,
          :data_set_location, :scraper_id, :frequency_id
        )

      attrs[:current_account] = current_account
      attrs
    end

    def scrape_ability_comment_param
      params.require(:scrape_ability_comment).permit(:body)
    end

    def datasource_comment_param
      params.require(:datasource_comment).permit(:body)
    end

    def general_comment_param
      params.require(:general_comment).permit(:body)
    end
  end
end
