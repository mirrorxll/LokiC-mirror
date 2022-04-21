# frozen_string_literal: true

module StoryTypes
  class StagingTableAttachingTask < StoryTypesTask
    def perform(story_type_id, account_id, staging_table_name)
      story_type = StoryType.find(story_type_id)
      account = Account.find(account_id)
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
