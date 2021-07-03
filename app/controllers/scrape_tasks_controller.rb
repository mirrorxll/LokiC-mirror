# frozen_string_literal: true

class ScrapeTasksController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :grid, only: :index

  def index
    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page]) }
      end

      f.csv do
        send_data(
          @grid.to_csv,
          type: 'text/csv',
          disposition: 'inline',
          filename: "scrape_tasks_#{Time.now}.csv"
        )
      end
    end
  end

  def show

  end

  def create
    @scrape_task = ScrapeTask.create!(new_scrape_task_params)
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

  def new_scrape_task_params
    sc_task_params = params.require(:scrape_task).permit(:name, :datasource_url, :notes_on_datasource)
    sc_task_params[:creator] = current_account

    if sc_task_params[:notes_on_datasource].present?
      sc_task_params[:notes_on_datasource] = Text.new(body: sc_task_params[:notes_on_datasource])
    else
      sc_task_params.reject! { |k, _v| k.eql?('notes_on_datasource') }
    end

    sc_task_params
  end
end
