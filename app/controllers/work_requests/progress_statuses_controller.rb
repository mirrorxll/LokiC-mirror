# frozen_string_literal: true

module WorkRequests
  class ProgressStatusesController < WorkRequestsController
    before_action :find_work_request
    before_action :find_status

    def update
      @work_request.status_comment.update!(body: params[:reasons]) if params[:reasons]
      @work_request.update!(status: @status, current_account: current_account)
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
