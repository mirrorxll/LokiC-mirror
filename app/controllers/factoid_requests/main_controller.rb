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
      statuses = Status.factoid_request_statuses(created: true)
      @lists = HashWithIndifferentAccess.new

      @lists['created'] = { requester_id: current_account.id, status: statuses }  if @permissions['grid']['created']
      @lists['all'] = { status: statuses }                                        if @permissions['grid']['all']
      @lists['archived'] = { status: Status.find_by(name: 'archived') }           if @permissions['grid']['archived']
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

      return if @lists['created'] && @factoid_request.requester.eql?(current_account) && @factoid_request.status != archived
      return if @lists['all'] && @factoid_request.status != archived
      return if @lists['archived'] && @work_request.status.eql?(archived)

      flash[:error] = { factoid_requests: :unauthorized }
      redirect_back fallback_location: root_path
    end

    def factoid_request_params
      params
        .require(:factoid_request).permit!
        .merge({ account: current_account })
    end
  end
end
