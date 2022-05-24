# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :find_work_request

  private

  def find_work_request
    @work_request = WorkRequest.find(params[:id] || params[:work_request_id])
  end
end
