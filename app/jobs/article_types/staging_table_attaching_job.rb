# frozen_string_literal: true

module ArticleTypes
  class StagingTableAttachingJob < ArticleTypesJob
    def perform(article_type_id, account_id, staging_table_name)
      article_type = ArticleType.find(article_type_id)
      account = Account.find(account_id)
      status = true
      message = 'Success. Staging table attached'

      article_type.create_staging_table(name: staging_table_name)
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      article_type.update!(staging_table_attached: status, current_account: account)
      send_to_action_cable(article_type, :staging_table, message)
    end
  end
end
