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

      validate_params(article_type)

      loop do
        Factoids[].publish!(iteration, threads_count)

        last_export_batch = iteration.reload.last_export_batch_size.zero?
        break if last_export_batch
      end

      pub_f                       = PublishedFactoid.find_or_initialize_by(iteration: iteration)
      pub_f.article_type          = article_type
      pub_f.developer             = article_type.developer
      pub_f.date_export           = Date.today
      pub_f.count_factoids        = iteration.articles.count

      pub_f.save!

      note = MiniLokiC::Formatize::Numbers.to_text(pub_f.count_factoids).capitalize
      record_to_change_history(article_type, 'published on limpar', note, account)

      if article_type.iterations.last.eql?(iteration) && !article_type.reload.status.name.in?(['canceled',
                                                                                              'blocked',
                                                                                              'on cron',
                                                                                              'exported'])
        article_type.update!(
          status: Status.find_by(name: 'exported'),
          current_account: account
        )
      end

    rescue StandardError, ScriptError, ArgumentError => e
      status = nil
      message = e.message
    ensure
      iteration.reload.update!(export: status)
      send_to_action_cable(article_type, :export, message)
      ArticleTypes::SlackNotificationJob.perform_now(iteration, 'export', message)
    end

    private

    def validate_params(article_type)
      %w[kind_id topic_id source_link source_type source_name original_publish_date].each do |field|
        raise ArgumentError, "#{field} must be provided!" unless article_type.attributes["#{field}"]
      end
    end
  end
end
