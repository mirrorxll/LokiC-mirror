# frozen_string_literal: true

module ScrapeTasks
  class TableLocationsController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      @scrape_task.table_locations.clear

      table_locations_params.each do |key, value|
        next if value.eql?('0')

        host_id, schema_id, sql_table_id = key.split('_')
        @scrape_task.table_locations.create(
          host: Host.find(host_id),
          schema: Schema.find(schema_id),
          sql_table: SqlTable.find(sql_table_id)
        )
      end

      render 'scrape_tasks/table_locations/show'
    end

    private

    def table_locations_params
      params[:table_locations] ? params.require(:table_locations).permit!.to_h : {}
    end
  end
end
