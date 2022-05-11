# frozen_string_literal: true

module Api
  class DataSamplesController < ApiController
    before_action :find_table_location, only: %i[show]
    before_action :open_connection, only: %i[show]
    after_action  :close_connection, only: %i[show]

    def show
      data_borders = data_sample_params
      data = @connection.query(data_query(data_borders), as: :array).to_a

      data.map! { |a| a.map! { |a2| CGI.escapeHTML(a2.to_s) } }

      total_records =
        if data_borders[:draw].eql?('1')
          total = @connection.query(total_records_query, as: :array).first[0]
          @table_location.update!(total_records: total)
          total
        else
          @table_location.total_records
        end

      render json: {
        draw: data_borders[:draw],
        recordsTotal: total_records,
        recordsFiltered: total_records,
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

    def find_table_location
      @table_location = TableLocation.find(params[:id])
    end

    def data_sample_params
      { draw: params[:draw], start: params[:start], length: params[:length], order: params[:order]&.fetch('0') }
    end

    def total_records_query
      "SELECT COUNT(*) count FROM `#{@table_location.table_name}`;"
    end

    def data_query(data_borders)
      query = "SELECT * FROM `#{@table_location.table_name}`"

      if !data_borders[:draw].eql?('1') && data_borders[:order]
        order = data_borders[:order]
        query += " ORDER BY `#{@table_location.table_columns[order[:column].to_i]}` #{order[:dir].upcase}"
      end

      "#{query} LIMIT #{data_borders[:length]} OFFSET #{data_borders[:start]};"
    end
  end
end
