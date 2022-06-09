# frozen_string_literal: true

module FactoidTypes
  class StagingTablesController < FactoidTypesController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :staging_table_name_from_params, only: :create
    before_action :staging_table

    def create
      flash.now[:error] =
        if @staging_table.present?
          @factoid_type.update!(staging_table_attached: true, current_account: current_account)
          'Table for this factoid type already exist. Please update the page.'
        elsif StagingTable.find_by(name: @staging_table_name)
          "Table with name '#{@staging_table_name}' already attached to another factoid type."
        elsif @staging_table_name.present? && StagingTable.not_exists?(@staging_table_name)
          "Table with name '#{@staging_table_name}' not exists."
        else
          @factoid_type.update!(staging_table_attached: false, current_account: current_account)
          StagingTableAttachingJob.perform_async(@factoid_type.id, current_account.id, @staging_table_name)
          nil
        end

      render 'show'
    end

    def sync
      staging_table_action { @staging_table.sync }

      render 'show'
    end

    def canceling_edit
      render 'show'
    end

    private

    def staging_table_name_from_params
      @staging_table_name = params.require(:staging_table).permit(:name)[:name]
    end

    def staging_table
      @staging_table = @factoid_type.staging_table
    end
  end
end
