
# frozen_string_literal: true

module StoryTypes
  class StagingTableIndexAddTask < StoryTypesTask
    def perform(staging_table_id, column_ids)
      staging_table = StagingTable.find(staging_table_id)
      message = "Success. Staging table's main index added"

      staging_table.index.add(:story_per_publication, column_ids.map!(&:to_sym))
      staging_table.sync
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
