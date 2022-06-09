# frozen_string_literal: true

module FactoidTypes
  class CreationJob < ArticleTypesJob
    def perform(iteration_id, account_id)
      iteration = ArticleTypeIteration.find(iteration_id)
      account = Account.find(account_id)

      options = {
        iteration: iteration,
        type: 'article'
      }

      status = true
      message = 'Success. All factoids have been created'

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
      SlackIterationNotificationJob.new.perform(iteration.id, 'creation', message)
    end
  end
end
