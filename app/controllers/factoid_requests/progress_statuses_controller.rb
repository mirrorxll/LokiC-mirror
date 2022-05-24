# frozen_string_literal: true

module FactoidRequests
  class ProgressStatusesController < FactoidRequestsController
    before_action :find_factoid_request
    before_action :find_status

    def update
      @factoid_request.status_comment.update!(body: params[:reasons]) if params[:reasons]
      @factoid_request.update!(status: @status, current_account: current_account)
    end

    private

    def find_factoid_request
      @factoid_request = FactoidRequest.find(params[:factoid_request_id])
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
