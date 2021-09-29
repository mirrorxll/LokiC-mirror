# frozen_string_literal: true

module Api
  class WorkRequestsController < ApiController
    def update
      WorkRequest.find(params[:id]).update(work_request_params)
    end

    private

    def work_request_params
      params.require(:work_request).permit(:billed_for_entire_project?, :r_val, :f_val, :last_invoice)
    end
  end
end
