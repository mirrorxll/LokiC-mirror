# frozen_string_literal: true

module StoryTypes
  class StagingTableIndexDropJob < StoryTypesJob
    def perform(staging_table)
      message = "Success. Staging table's main index dropped"

      staging_table.index.drop(:story_per_publication)
      staging_table.sync
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      staging_table.update!(indices_modifying: false)
      send_to_action_cable(staging_table.staging_tableable, :staging_table, message)
    end
  end
end
