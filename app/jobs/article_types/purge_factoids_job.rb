# frozen_string_literal: true

module ArticleTypes
  class PurgeFactoidsJob < ArticleTypesJob
    def perform(iteration_id, account_id, factoid_ids)
      iteration          = ArticleTypeIteration.find(iteration_id)
      account            = Account.find(account_id)
      message            = 'Success'
      article_type       = iteration.article_type
      staging_table_name = article_type.staging_table.name
      factoids           = iteration.articles.where(limpar_factoid_id: factoid_ids)
      pp '=== FACTOIDS ==='*10, factoids
      # remove factoids from Limpar
      Factoids::ExportToLp.new.unpublish!(iteration, factoid_ids)

      # update count of published factoids
      # pub_f = PublishedFactoid.find_by(iteration: iteration)
      # pub_f.update!(count_factoids: iteration.articles.count)
      pp '=== FACTOIDS ==='*10, factoids
      # remove rows from staging table
      st_table_rows = factoids.pluck(:staging_row_id)
      pp '=== ST_TABLE_ROWS ==='*10, st_table_rows

      Table.delete_rows_from_st_table(staging_table_name, st_table_rows)

      #remove created factoids from 'articles' table
      factoids.destroy_all

      note = MiniLokiC::Formatize::Numbers.to_text(iteration.articles.published.count)
      record_to_change_history(article_type, 'removed factoids from everywhere', note, account)

    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_export: false)
      send_to_action_cable(iteration.article_type, :export, message)
      ArticleTypes::SlackIterationNotificationJob.new.perform(iteration.id, 'remove from everywhere', message)
    end
  end
end

