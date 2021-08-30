# frozen_string_literal: true

module ArticleTypes
  class PurgeSamplesJob < ArticleTypesJob
    def perform(iteration, account)
      message = 'Success. samples have been removed'

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          iteration.articles.where(sampled: true).destroy_all
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
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(samples: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :samples, message)
    end
  end
end
