# frozen_string_literal: true

module FactoidTypes
  class StagingTableIndexDropJob < FactoidTypesJob
    def perform(staging_table_id)
      staging_table = StagingTable.find(staging_table_id)
      message = "Success. Staging table's uniq index dropped"
      staging_table.index.drop(:staging_table_uniq_row)
      staging_table.sync

    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
