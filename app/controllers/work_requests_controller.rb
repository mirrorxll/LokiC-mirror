# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :generate_grid, only: :index
  before_action :find_work_request, only: %i[show edit update]

  def index
    @grid.scope { |sc| sc.page(params[:page]).per(50) }
  end

  def show; end

  def new; end

  def create
    @request = WorkRequestObjectCreator.create_from!(current_account, work_request_params)
  end

  def edit; end

  def update; end

  private

  def generate_grid
    default = manager? || outside_manager? ? {} : { requester: current_account.id }
    @grid = request.parameters[:work_requests_grid] || default
    @grid = WorkRequestsGrid.new(@grid)
  end

  def work_request_params
    params.require(:work_request).permit!
  end

  def find_work_request
    @work_request = WorkRequest.find(params[:id])
  end
end
