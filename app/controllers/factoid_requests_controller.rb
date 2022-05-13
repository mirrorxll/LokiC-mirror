# frozen_string_literal: true

class FactoidRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :generate_grid, only: :index
  before_action :find_factoid_request, only: %i[show edit update archive unarchive]

  def index
    @tab_title = 'LokiC :: RequestedFactoids'
    @grid.scope { |sc| sc.page(params[:page]).per(100) }
  end

  def show
    @tab_title = "LokiC :: RequestedFactoid ##{@factoid_request.id} <#{@factoid_request.name}>"
  end

  def new; end

  def create
    @factoid_request = FactoidRequestObject.create_from!(
      factoid_request_params
    )

    redirect_to @factoid_request
  end

  def edit; end

  def update
    @factoid_request = FactoidRequestObject.update_from!(
      @factoid_request,
      factoid_request_params
    )

    redirect_to @factoid_request
  end

  private

  def generate_grid
    default = manager? ? {} : { requester: current_account.id }
    @grid = request.parameters[:factoid_requests_grid] || default
    @grid = FactoidRequestsGrid.new(@grid)
  end

  def factoid_request_params
    params
      .require(:factoid_request).permit!
      .merge({ account: current_account })
  end

  def find_factoid_request
    @factoid_request = FactoidRequest.find(params[:id])
  end
end
