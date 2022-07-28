# frozen_string_literal: true

module DataSets
  class ScrapeTasksController < DataSetsController
    before_action :find_data_set

    def show; end

    def edit; end

    def update
      @data_set.scrape_tasks.clear

      scrape_tasks_params.keep_if { |_k, v| v.eql?('1') }.keys.each do |ds|
        @data_set.scrape_tasks << ScrapeTask.find(ds)
      end

      render 'data_sets/scrape_tasks/show'
    end

    private

    def scrape_tasks_params
      params[:scrape_tasks] ? params.require(:scrape_tasks).permit!.to_h : {}
    end
  end
end
