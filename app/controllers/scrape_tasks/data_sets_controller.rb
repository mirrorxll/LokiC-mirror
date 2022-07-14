# frozen_string_literal: true

module ScrapeTasks
  class DataSetsController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      @scrape_task.data_sets.clear

      multi_tasks_params.keep_if { |_k, v| v.eql?('1') }.keys.each do |t|
        @scrape_task.multi_tasks << Task.find(t)
      end

      render 'scrape_tasks/data_sets/show'
    end

    private

    def multi_tasks_params
      params[:data_sets] ? params.require(:data_sets).permit!.to_h : {}
    end
  end
end
