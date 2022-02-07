# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TableNamesController < ApiController
      before_action :open_connection
      after_action :close_connection

      def index
        tables = @connection.query('show tables;').to_a.map { |row| row.values[0] }

        render json: { table_names: tables }
      end

      private

      def open_connection
        host = Host.find(params[:host])
        schema = Schema.find(params[:schema])

        @connection = MiniLokiC::Connect::Mysql.on(Object.const_get(host.name), schema.name)
      end

      def close_connection
        @connection.close
      end
    end
  end
end
