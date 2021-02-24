class StagingTableColumnsJob < ApplicationJob
  queue_as :story_type

  def perform(staging_table)
    Process.wait(
      fork do
        message = "Success. Staging table's columns modified"

        staging_table.columns.modify(columns_front_params)
        staging_table.sync
      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        staging_table.update(columns_modifying: false)
        send_to_action_cable(staging_table.story_type.iteration, :columns, message)
      end
    )
  end
end
