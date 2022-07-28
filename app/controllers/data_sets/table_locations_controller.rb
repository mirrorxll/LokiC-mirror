# frozen_string_literal: true

module DataSets
  class TableLocationsController < DataSetsController
    before_action :find_data_set

    def show; end

    def edit; end

    def update
      @data_set.table_locations.clear

      table_locations_params.each do |key, value|
        next if value.eql?('0')

        host_id, schema_id, sql_table_id = key.split('_')
        @data_set.table_locations.create(
          host: Host.find(host_id),
          schema: Schema.find(schema_id),
          sql_table: SqlTable.find(sql_table_id)
        )
      end

      render 'data_sets/table_locations/show'
    end

    private

    def table_locations_params
      params[:table_locations] ? params.require(:table_locations).permit!.to_h : {}
    end
  end
end
