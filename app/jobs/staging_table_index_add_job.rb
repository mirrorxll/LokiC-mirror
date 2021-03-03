# frozen_string_literal: true

class StagingTableIndexAddJob < ApplicationJob
  queue_as :story_type

  def perform(staging_table, index)
    Process.wait(
      fork do
        message = "Success. Staging table's main index added"
        staging_table.index.add(index)
        staging_table.sync

      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        staging_table.update(indices_modifying: false)
        send_to_action_cable(staging_table.story_type.iteration, :indices, message)
      end
    )
  end
end
