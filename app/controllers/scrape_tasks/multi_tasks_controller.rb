# frozen_string_literal: true

module ScrapeTasks
  class MultiTasksController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      @scrape_task.multi_tasks.clear

      multi_tasks_params.keep_if { |_k, v| v.eql?('1') }.keys.each do |t|
        @scrape_task.multi_tasks << Task.find(t)
      end

      render 'scrape_tasks/multi_tasks/show'
    end

    private

    def multi_tasks_params
      params[:multi_tasks] ? params.require(:multi_tasks).permit!.to_h : {}
    end
  end
end
