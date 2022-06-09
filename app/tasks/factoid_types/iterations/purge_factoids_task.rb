# frozen_string_literal: true

module FactoidTypes
  module Iterations
    class PurgeFactoidsTask < FactoidTypesTask
      def perform(iteration_id, account_id, factoid_ids)
        iteration          = ArticleTypeIteration.find(iteration_id)
        account            = Account.find(account_id)
        array_of_dis       = factoid_ids.split(',')
        message            = 'Success'
        article_type       = iteration.article_type
        factoids           = iteration.articles.where(limpar_factoid_id: array_of_dis)
        staging_table_name = article_type.staging_table.name
        st_table_rows      = factoids.pluck(:staging_row_id)

        Table.delete_rows_from_st_table(staging_table_name, st_table_rows)
        Factoids::ExportToLp.new.unpublish!(iteration, array_of_dis)

        note = MiniLokiC::Formatize::Numbers.to_text(iteration.articles.published.count)
        record_to_change_history(article_type, 'removed factoids from everywhere', note, account)

      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        iteration.update!(purge_export: false)
        send_to_action_cable(iteration.article_type, :export, message)

        SlackIterationNotificationTask.new.perform(iteration.id, 'remove from everywhere', message)
      end
    end
  end
end
