# frozen_string_literal: true

module FactoidTypes
  class StagingTableIndicesController < FactoidTypesController
    before_action :staging_table

    def new
      staging_table_action do
        @staging_table.index.drop(:staging_table_uniq_row)
        @staging_table.sync
        @columns = @staging_table.reload.columns.names_ids
        nil
      end
    end

    def create
      staging_table_action do
        @staging_table.update!(indices_modifying: true)
        StagingTableIndexAddJob.perform_async(@staging_table.id, uniq_index_column_ids)
        nil
      end

      render 'factoid_types/staging_tables/show'
    end

    def destroy
      staging_table_action do
        @staging_table.update!(indices_modifying: true)
        StagingTableIndexDropJob.perform_async(@staging_table.id)
        nil
      end

      render 'factoid_types/staging_tables/show'
    end

    private

    def uniq_index_column_ids
      if params[:index]
        params.require(:index).permit(column_ids: [])[:column_ids]
      else
        []
      end
    end

    def staging_table
      @staging_table = @factoid_type.staging_table
    end
  end
end
