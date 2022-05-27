# frozen_string_literal: true

module FactoidRequests
  class MainController < FactoidRequestsController
    before_action :generate_grid, only: :index
    before_action :find_factoid_request, only: %i[show edit update archive unarchive]

    def index
      @tab_title = 'LokiC :: FactoidRequests'
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def show
      @tab_title = "LokiC :: RequestedFactoid ##{@request.id} <#{@request.name}>"
    end

    def new; end

    def create
      @request =
        FactoidRequestObject.create_from!(factoid_request_params)

      redirect_to @request
    end

    def edit; end

    def update
      @request =
        FactoidRequestObject.update_from!(@request, factoid_request_params)

      redirect_to @request
    end

    private

    def generate_grid
      default =
        case params[:list]
        when 'all'
          {}
        else
          { requester_id: current_account.id }
        end
      filter_params = params[:factoid_requests_grid] || default

      @grid = FactoidRequestsGrid.new(filter_params)
    end

    def factoid_request_params
      params
        .require(:factoid_request).permit!
        .merge({ account: current_account })
    end
  end
end
