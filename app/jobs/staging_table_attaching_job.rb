class StagingTableAttachingJob < ApplicationJob
  queue_as :story_type

  def perform(story_type, staging_table_name)
    Process.wait(
      fork do
        status = true
        message = 'Success. Staging table attached'

        story_type.create_staging_table(name: staging_table_name)
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        story_type.update(staging_table_attached: status)
        send_to_action_cable(story_type.iteration, :staging_table, message)
      end
    )
  end
end
