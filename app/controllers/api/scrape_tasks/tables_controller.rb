# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TablesController < ApiController
      before_action :find_scrape_task, only: %i[create destroy]
      before_action :open_connection, only: :index
      after_action  :close_connection, only: :index
      before_action :find_table, only: :destroy

      def index
        tables = @connection.query('show tables;').to_a.map { |row| row.values[0] }

        render json: { table_names: tables }
      end

      def create
        tables = ScrapeTaskTables.attach(@scrape_task, table_params)

        render json: { tables: tables }
      end

      def destroy
        not_exist =
          if @scrape_task.tables.exists?(@task.id)
            @scrape_task.tables.destroy(@task)
            false
          else
            true
          end

        render json: { not_exist: not_exist }
      end

      private

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id])
      end

      def open_connection
        host = Host.find(params[:host_id])
        schema = Schema.find(params[:schema_id])

        @connection = MiniLokiC::Connect::Mysql.on(Object.const_get(host.name), schema.name)
      end

      def close_connection
        @connection.close
      end

      def table_params
        params.require(:tables).permit(:host_id, :schema_id, names: [])
      end
    end
  end
end
