# frozen_string_literal: true

module ScrapeTasks
  class DataSamplesController < ScrapeTasksController
    before_action :find_scrape_task

    def show
      connections = {}

      @locations_columns = @scrape_task.table_locations.each_with_object({}) do |loc, obj|
        connections[loc.host_name] ||= MiniLokiC::Connect::Mysql.on(Object.const_get(loc.host_name))
        query = "SHOW COLUMNS FROM `#{loc.schema_name}`.`#{loc.table_name}`;"
        columns = connections[loc.host_name].query(query).to_a.map { |col| col['Field'] }

        loc.update!(table_columns: columns)

        obj[loc.full_name] = { table_location_id: loc.id, list: columns }
      end

      connections.each_value(&:close)
    end
  end
end
