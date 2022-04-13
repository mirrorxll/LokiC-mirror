# frozen_string_literal: true

module ArticleTypes
  class ExportJob < ArticleTypesJob
    def perform(iteration, account, url = nil)
      status = true
      message = 'Success. Make sure that all factoids are published'
      article_type = iteration.article_type
      threads_count = (iteration.articles.count / 75_000.0).ceil + 1
      threads_count = threads_count > 20 ? 20 : threads_count

      iteration.update!(last_export_batch_size: nil)

      loop do
        Factoids[].publish!(iteration, threads_count)

        last_export_batch = iteration.reload.last_export_batch_size.zero?
        break if last_export_batch
      end

      pub_f                       = PublishedFactoid.find_or_initialize_by(iteration: iteration)
      pub_f.article_type          = article_type
      pub_f.developer             = article_type.developer
      pub_f.original_publish_date = Date.today
      pub_f.count_factoids        = iteration.articles.count

      pub_f.save!
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      iteration.reload.update!(export: status)
      send_to_action_cable(article_type, :export, message)
    end
  end
end
