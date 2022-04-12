# frozen_string_literal: true

module ArticleTypes
  class StagingTableIndexAddJob < ArticleTypesJob
    def perform(staging_table_id, column_ids)
      staging_table = StagingTable.find(staging_table_id)
      message = "Success. Staging table's uniq index added"

      staging_table.index.add(:staging_table_uniq_row, column_ids.map!(&:to_sym))
      staging_table.sync

    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
