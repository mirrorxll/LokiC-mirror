# frozen_string_literal: true

module WorkRequests
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_work_request
    before_action :find_status

    def change
      @work_request.status_comment.update!(body: params[:reasons]) if params[:reasons]
      @work_request.update!(status: @status, current_account: current_account)
    end

    private

    def find_work_request
      @work_request = WorkRequest.find(params[:work_request_id])
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
