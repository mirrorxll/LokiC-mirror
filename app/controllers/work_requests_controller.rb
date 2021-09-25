# frozen_string_literal: true

class WorkRequestsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :generate_grid, only: :index

  def index
    @grid.scope { |sc| sc.page(params[:page]).per(50) }
  end

  def show

  end

  def new

  end

  def create
    puts params
  end

  def edit

  end

  def update

  end

  private

  def generate_grid
    @grid = request.parameters[:work_request_grid] || {}
    @grid = WorkRequestsGrid.new(@grid)
  end
end
