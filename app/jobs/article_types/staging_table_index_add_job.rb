# frozen_string_literal: true

module ArticleTypes
  class StagingTableIndexAddJob < ArticleTypesJob
    def perform(staging_table, column_ids)
      message = "Success. Staging table's uniq index added"
      staging_table.index.add(:staging_table_uniq_row, column_ids)
      staging_table.sync

    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
