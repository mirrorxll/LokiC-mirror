# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :generate_grid, only: :index
  before_action :find_work_request, only: %i[show edit update archive unarchive]

  def index
    @grid.scope { |sc| sc.page(params[:page]).per(100) }
  end

  def show
    @delete_status = Status.find_by(name: 'deleted')
  end

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

  def archive
    @work_request.update!(archived: true)
  end

  def unarchive
    @work_request.update!(archived: false)
  end

  private

  def john_putz_slack_id
    "<@#{Account.find(4).slack_identifier}" # John Putz slack ID
  end

  def generate_grid
    default = manager? ? {} : { requester: current_account.id }
    @grid = request.parameters[:work_requests_grid] || default
    @grid = WorkRequestsGrid.new(@grid) do |scope|
      archived = params[:archived].nil? ? false : params[:archived]
      scope.where(archived: archived)
    end

    @grid.column(:project_order_name, after: :priority) do |req|
      WorkRequestsGrid.format(req) do
        name = req.project_order_name.body
        truncated = "##{req.id} #{name.truncate(30)}"
        link_to(truncated, req)
      end
    end

    return unless manager?

    @grid.column(:sow, header: 'SOW', after: :project_order_name) do |req|
      WorkRequestsGrid.format(req) { (render 'work_requests/sow_cell', work_request: req, default: req.default_sow).to_s }
    end
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
