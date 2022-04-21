# frozen_string_literal: true

module FactoidRequests
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_factoid_request
    before_action :find_status

    def change
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
