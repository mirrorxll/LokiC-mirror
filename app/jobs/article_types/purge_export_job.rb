# frozen_string_literal: true

module FactoidTypes
  class PurgeExportJob < ArticleTypesJob
    def perform(iteration_id, account_id)
      iteration     = ArticleTypeIteration.find(iteration_id)
      account       = Account.find(account_id)
      purge_status  = false
      export_status = nil
      message       = 'Success'
      article_type  = iteration.article_type

      loop do
        break if iteration.articles.reload.published.count.zero?

        Factoids::ExportToLp.new.unpublish!(iteration)
      end

      iteration.published&.destroy

      note = MiniLokiC::Formatize::Numbers.to_text(iteration.articles.published.count)
      record_to_change_history(article_type, 'removed from limpar', note, account)

      old_status        = article_type.status.name
      last_iteration    = article_type.reload.iterations.last.eql?(iteration)
      changeable_status = !article_type.status.name.in?(['canceled', 'blocked', 'on cron'])

      if !old_status.eql?('in progress') && last_iteration && changeable_status
        article_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
      end

    rescue StandardError, ScriptError => e
      message       = e.message
      export_status = true
    ensure
      iteration.update!(purge_export: purge_status, export: export_status)
      send_to_action_cable(iteration.article_type, :export, message)
      ArticleTypes::SlackIterationNotificationJob.new.perform(iteration.id, 'remove from limpar', message)
    end
  end
end
