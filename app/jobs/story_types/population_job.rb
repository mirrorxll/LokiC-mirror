# frozen_string_literal: true

# Execute population method on sidekiq backend
module StoryTypes
  class PopulationJob < StoryTypesJob
    def perform(iteration, account, options = {})
      status = true
      message = 'Success'
      story_type = iteration.story_type
      population_args = population_args_to_hash(options[:population_args])
      story_type.sidekiq_break.update!(cancel: false)
      # SidekiqBreak.create_with(cancel: false).find_or_create_by(story_type: story_type)

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          MiniLokiC::StoryTypeCode[story_type].execute(:population, population_args)

          unless story_type.status.name.in?(['in progress', 'on cron'])
            story_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
          end

          ExportConfigurationsJob.perform_now(story_type, account)
        rescue StandardError, ScriptError => e
          wr.write({ e.class.to_s => e.message }.to_json)
        ensure
          wr.close
        end
      )

      if story_type.sidekiq_break.cancel
        status = nil
        message = 'Canceled'
      end

      wr.close
      exception = rd.read
      rd.close

      if exception.present?
        klass, message = JSON.parse(exception).to_a.first
        raise Object.const_get(klass), message
      end

      false
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
      true
    ensure
      iteration.update!(population: status, current_account: account)
      story_type.sidekiq_break.update!(cancel: false)
      send_to_action_cable(story_type, :staging_table, message)
      StoryTypes::SlackNotificationJob.perform_now(iteration, 'population', message)
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
