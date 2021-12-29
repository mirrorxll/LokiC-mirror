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

    @grid.column(:project_order_name, after: :priority) do |req|
      WorkRequestsGrid.format(req) do
        name = req.project_order_name.body
        truncated = "##{req.id} #{name.truncate(30)}"
        link_to(truncated, req)
      end
    end

    return unless manager?

    @grid.column(:sow, header: 'SOW', after: :project_order_name) do |req|
      WorkRequestsGrid.format(req) do
        content_tag(:div, id: "sow#{req.id}", class: 'text-center') do
          if req.default_sow
            content_tag(
              :u, 'Create SOW',
              'class' => 'mouse-hover',
              'data-container' => 'body',
              'data-toggle' => 'popover',
              'data-placement' => 'top',
              'data-html' => 'true',
              'data-content' => (render 'work_requests/index__sow_form', work_request: req).to_s
            )
          else
            sow = {
              name: (req.sow[/document/] ? 'Google Document' : 'Google Sheet'),
              link: req.sow
            }

            link_to(sow[:name], sow[:link], target: '_blank', rel: 'noopener noreferrer')
          end
        end
      end
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
