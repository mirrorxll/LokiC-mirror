# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TablesController < ApiController
      before_action :open_connection, only: %i[index show]
      after_action  :close_connection, only: %i[index show]
      before_action :find_scrape_task, only: %i[create destroy]
      before_action :find_table, only: :destroy

      def index
        tables = @connection.query('show tables;').to_a.map { |row| row.values[0] }

        render json: { table_names: tables }
      end

      def show

      end

      def create
        tables = ScrapeTaskTables.attach(@scrape_task, table_params)

        render json: { tables: tables }
      end

      def update

      end

      def destroy
        render json: { not_deleted: !@table.destroy }
      end

      private

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

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id])
      end

      def find_table
        @table = TableLocation.find(params[:id])
      end
    end
  end
end
