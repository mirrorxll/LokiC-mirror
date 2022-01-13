# frozen_string_literal: true

module WorkRequests
  class SowCellsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_work_request

    def change
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
