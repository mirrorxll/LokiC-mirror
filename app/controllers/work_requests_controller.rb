# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :generate_grid, only: :index
  before_action :find_work_request, only: %i[show edit update]

  def index
    @grid.scope { |sc| sc.page(params[:page]).per(100) }
  end

  def show; end

  def new; end

  def create
    @request =
      WorkRequestObject.create_from!(work_request_params)
    WorkRequests::SlackNotificationJob.perform_later(
      @request,
      '<!channel> Just was created a new work request. Check it'
    )
  end

  def edit; end

  def update
    @work_request =
      WorkRequestObject.update_from!(@work_request, work_request_params)
  end

  private

  def john_putz_slack_id
    "<@#{Account.find(4).slack_identifier}" # John Putz slack ID
  end

  def generate_grid
    default = manager? || outside_manager? ? {} : { requester: current_account.id }
    @grid = request.parameters[:work_requests_grid] || default
    @grid = WorkRequestsGrid.new(@grid)
  end

  def work_request_params
    params
      .require(:work_request).permit!
      .merge({ account: current_account })
  end

  def find_work_request
    @work_request = WorkRequest.find(params[:id])
  end
end
