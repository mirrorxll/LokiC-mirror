# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  before_action -> { authorize!('work_requests') }

  private

  def find_work_request
    @work_request = WorkRequest.find(params[:work_request_id] || params[:id])
  end
end
