# frozen_string_literal: true

class ScrapeTasksController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :grid, only: :index
  before_action :find_scrape_task, only: %i[show edit cancel_edit update evaluate]
  before_action :find_data_set, only: %i[show edit cancel_edit update evaluate], if: :manager?

  def index
    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page]).per(50) }
      end
    end
  end

  def show; end

  def create
    @scrape_task = ScrapeTask.create!(create_scrape_task_params)
  end

  def edit; end

  def cancel_edit; end

  def update
    sc_task_params = update_scrape_task_params

    @scrape_task.transaction do
      @scrape_task.datasource_comment.update(body: sc_task_params.delete(:datasource_comment))
      @scrape_task.scrape_ability_comment.update(body: sc_task_params.delete(:scrape_ability_comment))
      @scrape_task.update!(sc_task_params)
    end
  end

  def evaluate
    @scrape_task.update(evaluation: true)
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
    sc_task_params = params.require(:scrape_task).permit(:name, :datasource_url, :datasource_comment).to_h
    sc_task_params[:creator] = current_account

    subtype = CommentSubtype.find_or_create_by!(name: 'datasource comment')
    sc_task_params[:datasource_comment] = Comment.new(body: sc_task_params[:datasource_comment], subtype: subtype)

    sc_task_params
  end

  def update_scrape_task_params
    params.require(:scrape_task).permit(
      :name, :gather_task, :scrapable,
      :scrape_ability_comment, :datasource_url,
      :datasource_comment, :data_set_location,
      :scraper_id, :frequency_id
    ).to_h
  end
end
