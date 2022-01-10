# frozen_string_literal: true

module Api
  class WorkRequestsController < ApiController
    def update
      success = WorkRequest.find(params[:id]).update(work_request_params)

      render json: { success: success }
    end

    private

    def work_request_params
      params.require(:work_request).permit(
        :billed_for_entire_project?, :r_val,
        :f_val, :last_invoice, :eta, :sow
      )
    end
  end
end
