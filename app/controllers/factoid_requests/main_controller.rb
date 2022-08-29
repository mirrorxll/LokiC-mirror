# frozen_string_literal: true

module FactoidRequests
  class MainController < FactoidRequestsController
    before_action :find_factoid_request, only: %i[show edit update]

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    before_action :access_to_show, only: :show

    def index
      @tab_title = 'LokiC :: FactoidRequests'
    end

    def show
      @tab_title = "LokiC :: FactoidRequest ##{@factoid_request.id} <#{@factoid_request.name}>"
    end

    def new; end

    def create
      @factoid_request =
        FactoidRequestObject.create_from!(factoid_request_params)

      redirect_to @factoid_request
    end

    def edit; end

    def update
      @factoid_request =
        FactoidRequestObject.update_from!(@factoid_request, factoid_request_params)

      redirect_to @factoid_request
    end

    private

    def grid_lists
      status_ids = Status.factoid_request_statuses(created: true).ids.map(&:to_s)
      @lists = HashWithIndifferentAccess.new

      if @factoid_requests_permissions['grid']['created']
        @lists['created'] =
          { requester: @current_account.id.to_s, status: status_ids }
      end
      if @factoid_requests_permissions['grid']['all']
        @lists['all'] =
          { status: status_ids }
      end
      if @factoid_requests_permissions['grid']['archived']
        @lists['archived'] =
          { status: Status.find_by(name: 'archived').id.to_s }
      end
    end

    def current_list
      keys = @lists.keys
      @current_list = keys.include?(params[:list]) ? params[:list] : keys.first
    end

    def generate_grid
      return unless @current_list

      @grid = FactoidRequestsGrid.new(params[:factoid_requests_grid] || @lists[@current_list])
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def access_to_show
      archived = Status.find_by(name: 'archived')

      if @lists['created'] && @factoid_request.requester.eql?(@current_account) && @factoid_request.status != archived
        return
      end
      return if @lists['all'] && @factoid_request.status != archived
      return if @lists['archived'] && @work_request.status.eql?(archived)

      flash[:error] = { factoid_requests: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def factoid_request_params
      params
        .require(:factoid_request).permit!
        .merge({ account: @current_account })
    end
  end
end
