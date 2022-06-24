# frozen_string_literal: true

class FactoidRequestsController < ApplicationController
  before_action -> { authorize!('factoid_requests') }

  private

  def find_factoid_request
    @factoid_request = FactoidRequest.find(params[:factoid_request_id] || params[:id])
  end
end
