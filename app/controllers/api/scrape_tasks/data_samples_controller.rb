# frozen_string_literal: true

module Api
  module ScrapeTasks
    class DataSamplesController < ApiController
      before_action :find_table_location, only: %i[show destroy]
      before_action :open_connection, only: %i[index show]
      after_action  :close_connection, only: %i[index show]

      before_action :find_scrape_task, only: %i[create destroy]

      def show
        data_borders = data_sample_params
        data = @connection.query(
          data_query(data_borders),
          as: :array
        ).to_a

        render json: {
          draw: data_borders[:draw],
          data: data
        }
      end

      private

      def open_connection
        host = Host.find(@table_location.host.id)
        schema = Schema.find(@table_location.schema.id)

        @connection = MiniLokiC::Connect::Mysql.on(Object.const_get(host.name), schema.name)
      end

      def close_connection
        @connection.close
      end

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id])
      end

      def find_table_location
        @table_location = TableLocation.find(params[:id])
      end

      def data_sample_params
        { draw: params[:draw], start: params[:start], length: params[:length] }
      end

      def data_query(data_borders)
        "SELECT *
         FROM #{@table_location.table_name}
         LIMIT #{data_borders[:length]} OFFSET #{data_borders[:start]};"
      end
    end
  end
end
