# frozen_string_literal: true

module WorkRequests
  class SowCellsController < WorkRequestsController
    before_action :find_work_request

    def update
      @work_request.update(sow_params)
    end

    private

    def find_work_request
      @work_request = WorkRequest.find(params[:work_request_id])
    end

    def sow_params
      params.require(:work_request).permit(:sow)
    end
  end
end
