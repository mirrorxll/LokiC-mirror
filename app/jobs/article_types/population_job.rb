# frozen_string_literal: true

# Execute population method on sidekiq backend
module ArticleTypes
  class PopulationJob < ArticleTypesJob
    def perform(iteration, account, options)
      status = true
      message = 'Success'
      article_type = iteration.article_type
      population_args = population_args_to_hash(options[:population_args])

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          MiniLokiC::ArticleTypeCode[article_type].execute(:population, population_args)

          unless article_type.status.name.eql?('in progress')
            article_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
          end
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

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      iteration.update!(population: status, current_account: account)
      send_to_action_cable(article_type, :staging_table, message)
      SlackNotificationJob.perform_now(iteration.article_type, iteration, 'population', message)
    end

    private

    def population_args_to_hash(args)
      args.split(' :: ').each_with_object({}) do |option, hash|
        next unless option.match?(/=>/)

        key, value = option.split('=>')
        hash[key] = value
      end
    end
  end
end
