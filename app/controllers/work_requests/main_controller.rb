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
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def show
      @tab_title = "LokiC :: WorkRequest ##{@work_request.id} <#{@work_request.project_order_name.body}>"
      @delete_status = Status.find_by(name: 'archived')
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
      statuses      = Status.work_request_statuses(created: true)
      allowed_grids = current_account.ordered_lists.where(branch_name: 'factoid_requests').order(:position)
      @lists        = HashWithIndifferentAccess.new

      allowed_grids.each do |grid|
        @lists[grid.grid_name] = { status: statuses }

        @lists[grid.grid_name].merge!(requester: current_account)               if grid.grid_name.eql?('created')
        @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived')) if grid.grid_name.eql?('archived')
      end
    end

    def current_list
      keys = @lists.keys
      @current_list =
        if keys.include?(params[:list])
          params[:list]
        else
          first_grid = current_account.ordered_lists.first_grid('work_requests')
          current_account.manager? && @lists['all'] ? 'all' : first_grid
        end
    end

    def generate_grid
      return unless @current_list

      @grid = WorkRequestsGrid.new(params[:work_requests_grid]) do |scope|
        scope.where(@lists[@current_list])
      end
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      return if @lists['created'] && @work_request.requester.eql?(current_account) && @work_request.status != archived
      return if @lists['all'] && @work_request.status != archived
      return if @lists['archived'] && @work_request.status.eql?(archived)

      flash[:error] = { work_requests: :unauthorized }
      redirect_back fallback_location: root_path
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
