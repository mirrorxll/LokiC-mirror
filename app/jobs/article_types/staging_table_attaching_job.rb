# frozen_string_literal: true

module ArticleTypes
  class StagingTableAttachingJob < ArticleTypeJob
    def perform(article_type, account, staging_table_name)
      Process.wait(
        fork do
          status = true
          message = 'Success. Staging table attached'

          article_type.create_staging_table(name: staging_table_name)
        rescue StandardError => e
          status = nil
          message = e.message
        ensure
          article_type.update!(staging_table_attached: status, current_account: account)
          send_to_action_cable(article_type, :staging_table, message)
        end
      )
    end
  end
end
