# frozen_string_literal: true

module ArticleTypes
  class PurgeCreationJob < ArticleTypesJob
    def perform(iteration, account)
      message = 'Success. All articles have been removed'

      loop do
        rd, wr = IO.pipe

        Process.wait(
          fork do
            rd.close

            iteration.articles.limit(10_000).destroy_all
          rescue StandardError, ScriptError => e
            wr.write({ e.class.to_s => e.message }.to_json)
          ensure
            wr.close
          end
        )

        wr.close
        exception = rd.read
        rd.close

        if exception.present?
          klass, message = JSON.parse(exception).to_a.first
          raise Object.const_get(klass), message
        end

        break if iteration.articles.reload.blank?
      end

      iteration.update!(samples: nil, creation: nil, current_account: account)
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_creation: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :samples, message)
      SlackNotificationJob.perform_now(iteration, 'creation', message)
    end
  end
end
