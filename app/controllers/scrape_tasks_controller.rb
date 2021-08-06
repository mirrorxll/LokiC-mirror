# frozen_string_literal: true

class ScrapeTasksController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :grid, only: :index
  before_action :find_scrape_task, only: %i[show edit cancel_edit update evaluate]
  before_action :find_data_set,    only: %i[show edit cancel_edit evaluate], if: :manager?

  def index
    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page]).per(50) }
      end
    end
  end

  def show; end

  def create
    @scrape_task = ScrapeTask.new(create_scrape_task_params)
    @scrape_task.creator = current_account
    @scrape_task.save!
  end

  def edit; end

  def cancel_edit; end

  def update
    render_403 and return if !manager? && !@scrape_task.scraper.eql?(current_account)

    @scrape_task.transaction do
      @scrape_task.datasource_comment.update!(datasource_comment_param)
      @scrape_task.scrape_ability_comment.update!(scrape_ability_comment_param)
      @scrape_task.general_comment.update!(general_comment_param)
      @scrape_task.update!(update_scrape_task_params)
    end

    return unless manager?

    @scrape_task.data_set&.update!(scrape_task: nil)
    @data_set = DataSet.find_by(data_set_param) || DataSet.new
    @data_set.update!(scrape_task: @scrape_task) if @data_set.persisted?
  end

  def evaluate
    @scrape_task.update!(current_account: current_account, evaluation: true)
  end

  private

  def grid
    grid_params =
      if params[:scrape_tasks_grid]
        params.require(:scrape_tasks_grid).permit!
      else
        { order: :id, descending: true }
      end

    @grid = ScrapeTasksGrid.new(grid_params)
  end

  def find_scrape_task
    @scrape_task = ScrapeTask.find(params[:id] || params[:scrape_task_id])
  end

  def find_data_set
    @data_set = @scrape_task.data_set || DataSet.new
  end

  def create_scrape_task_params
    params.require(:scrape_task).permit(:name)
  end

  def update_scrape_task_params
    attrs =
      if manager?
        params.require(:scrape_task).permit(
          :name, :gather_task, :state_id, :datasource_url,
          :scrapable, :data_set_location, :scraper_id, :frequency_id
        )
      elsif @scrape_task.scraper.eql?(current_account)
        params.require(:scrape_task).permit(
          :gather_task, :datasource_url, :data_set_location
        )
      else
        {}
      end

    attrs[:current_account] = current_account
    attrs
  end

  def scrape_ability_comment_param
    params.require(:scrape_ability_comment).permit(:body)
  end

  def datasource_comment_param
    params.require(:datasource_comment).permit(:body)
  end

  def general_comment_param
    params.require(:general_comment).permit(:body)
  end

  def data_set_param
    params.require(:data_set).permit(:id)
  end
end
