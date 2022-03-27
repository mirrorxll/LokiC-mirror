# frozen_string_literal: true

module StoryTypes
  class StagingTableAttachingJob < StoryTypesJob
    def perform(story_type, account, staging_table_name)
      status = true
      message = 'Success. Staging table attached'

      story_type.create_staging_table(name: staging_table_name)
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      story_type.update!(staging_table_attached: status, current_account: account)
      send_to_action_cable(story_type, :staging_table, message)
    end
  end
end
