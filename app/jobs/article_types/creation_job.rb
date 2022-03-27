# frozen_string_literal: true

module ArticleTypes
  class CreationJob < ArticleTypesJob
    def perform(iteration, account, options = {})
      options[:iteration] = iteration
      options[:type] = 'article'

      status = true
      message = 'Success. All articles have been created'

      loop do
        MiniLokiC::ArticleTypeCode[iteration.article_type].execute(:creation, options)

        staging_table = iteration.article_type.staging_table.name
        break if Table.all_articles_created_by_iteration?(staging_table)
      end

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      iteration.update!(creation: status, current_account: account)
      send_to_action_cable(iteration.article_type, :stories, message)
      SlackNotificationJob.perform_now(iteration.article_type, iteration, 'creation', message)
    end
  end
end
