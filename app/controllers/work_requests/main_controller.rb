# frozen_string_literal: true

module WorkRequests
  class MainController < WorkRequestsController
    skip_before_action :find_work_request, only: %i[index new create]
    before_action :generate_grid, only: :index

    def index
      @tab_title = 'LokiC :: WorkRequests'
      @grid.scope { |sc| sc.page(params[:page]).per(3) }
    end

    def show
      @tab_title = "LokiC :: WorkRequest ##{@work_request.id} <#{@work_request.project_order_name.body}>"
      @delete_status = Status.find_by(name: 'deleted')
    end

    def new; end

    def create
      @request =
        WorkRequestObject.create_from!(work_request_params)
      WorkRequests::SlackNotificationJob.perform_async(
        @request.id,
        '<!channel> Just was created a new work request. Check it'
      )
    end

    def edit; end

    def update
      @work_request =
        WorkRequestObject.update_from!(@work_request, work_request_params)
    end

    private

    def john_putz_slack_id
      "<@#{Account.find(4)&.slack_identifier}" # John Putz slack ID
    end

    def generate_grid
      default =
        case params[:list]
        when 'all'
          { archived: false }
        when 'yours', nil
          { requester_id: current_account.id, archived: false }
        when 'archived'
          { archived: true }
        end
      filter_params = params[:work_requests_grid] || default

      @grid = WorkRequestsGrid.new(filter_params)
      return unless manager?

      @grid.column(:sow, header: 'SOW', order: false, after: :project_order_name) do |req|
        WorkRequestsGrid.format(req) do
          (render 'work_requests/main/sow_cell', work_request: req, default: req.default_sow).to_s
        end
      end
    end

    def work_request_params
      params
        .require(:work_request).permit!
        .merge({ account: current_account })
    end

    def find_work_request
      @work_request = WorkRequest.find(params[:id])
    end
  end
end
