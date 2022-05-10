# frozen_string_literal: true

module StoryTypes
  class StagingTableColumnsTask < StoryTypesTask
    def perform(staging_table_id, columns)
      staging_table = StagingTable.find(staging_table_id)
      message = "Success. Staging table's columns modified"

      staging_table.columns.modify(
        Table.columns_transform(columns.deep_symbolize_keys!, :front)
      )
      staging_table.sync
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(columns_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
