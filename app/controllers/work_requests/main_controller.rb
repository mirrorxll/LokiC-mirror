# frozen_string_literal: true

module WorkRequests
  class MainController < WorkRequestsController
    before_action :find_work_request, only: %i[show update]

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    before_action :access_to_show, only: :show
    before_action :multi_tasks_access, only: :show

    def index
      @tab_title = 'LokiC :: WorkRequests'
    end

    def show
      @tab_title = "LokiC :: WorkRequest ##{@work_request.id} <#{@work_request.project_order_name.body}>"
      @delete_status = Status.find_by(name: 'deleted')
    end

    def create
      @work_request =
        WorkRequestObject.create_from!(work_request_params)

      redirect_to @work_request
    end

    def update
      @work_request =
        WorkRequestObject.update_from!(@work_request, work_request_params)

      redirect_to @work_request
    end

    private

    def grid_lists
      @lists = HashWithIndifferentAccess.new

      @lists['your'] = { requester_id: current_account.id, archived: false } if @permissions['grid']['your']
      @lists['all'] = { archived: false }                                    if @permissions['grid']['all']
      @lists['archived'] = { archived: true }                                if @permissions['grid']['archived']
    end

    def current_list
      keys = @lists.keys
      @current_list = keys.include?(params[:list]) ? params[:list] : keys.first
    end

    def generate_grid
      return unless @current_list

      @grid = WorkRequestsGrid.new(params[:work_requests_grid] || @lists[@current_list])

      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def access_to_show
      return if @lists['your'] && @work_request.requester.eql?(current_account)
      return if @lists['all'] && !@work_request.archived
      return if @lists['archived'] && @work_request.archived

      flash[:error] = { work_requests: :unauthorized }
      redirect_to root_path
    end

    def multi_tasks_access
      card = current_account.cards.find_by(branch: Branch.find_by(name: 'multi_tasks'))
      @multi_tasks_permissions = card.access_level.permissions if card.enabled
    end

    def work_request_params
      params
        .require(:work_request).permit!
        .merge({ account: current_account })
    end
  end
end
