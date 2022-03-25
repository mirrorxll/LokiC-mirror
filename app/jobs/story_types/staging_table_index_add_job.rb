# frozen_string_literal: true

module StoryTypes
  class StagingTableIndexAddJob < StoryTypesJob
    def perform(staging_table, column_ids)
      message = "Success. Staging table's main index added"

      staging_table.index.add(:story_per_publication, column_ids)
      staging_table.sync
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
