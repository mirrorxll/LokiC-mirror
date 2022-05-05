# frozen_string_literal: true

module Api
  class TableLocationsController < ApiController
    before_action :open_connection, only: :index
    after_action  :close_connection, only: :index

    before_action :find_model, only: %i[create destroy]
    before_action :find_table_location, only: %i[destroy]

    def index
      tables = @connection.query('SHOW TABLES;').to_a.map { |row| row.values[0] }

      render json: { table_names: tables }
    end

    def create
      tables = AttachTableLocations.to(@model, table_location_params)

      render json: { locations: tables }
    end

    def destroy
      render json: { not_deleted: !@table_location.destroy }
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

    def table_location_params
      params.require(:tables).permit(:host_id, :schema_id, names: [])
    end

    def find_model
      @model = Object.const_get(params[:model]).find(params[:model_id])
    end

    def find_table_location
      @table_location = TableLocation.find(params[:id])
    end
  end
end
