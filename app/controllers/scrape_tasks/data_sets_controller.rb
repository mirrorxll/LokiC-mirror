# frozen_string_literal: true

module ScrapeTasks
  class DataSetsController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      @scrape_task.data_sets.clear

      data_sets_params.keep_if { |_k, v| v.eql?('1') }.keys.each do |ds|
        @scrape_task.data_sets << DataSet.find(ds)
      end

      render 'scrape_tasks/data_sets/show'
    end

    private

    def data_sets_params
      params[:data_sets] ? params.require(:data_sets).permit!.to_h : {}
    end
  end
end
