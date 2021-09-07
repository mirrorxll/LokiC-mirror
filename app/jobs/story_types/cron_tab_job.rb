# frozen_string_literal: true

module StoryTypes
  class CronTabJob < StoryTypesJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      cron_tab = story_type.cron_tab
      return if cron_tab.freeze_execution

      account = story_type.developer || Account.find_by(email: 'main@lokic.loc')
      iteration = story_type.cron_tab_iteration || story_type.create_cron_tab_iteration!
      staging_table = story_type.staging_table

      staging_table.default_iter_id(iteration.id)
      iteration.update!(population: false, population_args: cron_tab.population_params, current_account: account)
      population_raise = PopulationJob.perform_now(iteration, account, population_args: cron_tab.population_params)

      if population_raise
        Table.purge_last_iteration(staging_table.name)
        staging_table.default_iter_id(story_type.iteration.id)
        return
      end

      if Table.rows_absent?(staging_table.name, iteration.id)
        staging_table.default_iter_id(story_type.iteration.id)
        message = "Population didn't add new rows to staging table. "\
                  "New iteration didn't create. CronTab execution was stopped"
        SlackNotificationJob.perform_now(iteration, 'crontab', message)
        return
      else
        story_type.update!(current_iteration: iteration, current_account: account)
        iteration.update!(cron_tab: false)
        iteration.update!(name: DateTime.now.strftime('CT%Y%m%d')) if iteration.name.blank?
      end

      iteration.update!(samples: false, current_account: account)
      creation_raise = SamplesAndAutoFeedbackJob.perform_now(iteration, account, cron: true)

      return if creation_raise

      iteration.update!(creation: false, current_account: account)
      creation_raise = CreationJob.perform_now(iteration, account)

      return if creation_raise

      rd, wr = IO.pipe
      Process.wait(
        fork do
          rd.close

          wr.write({ 'scheduling' => iteration.stories.complete_scheduling? }.to_json)
          wr.close
        end
      )
      wr.close
      scheduling = JSON.parse(rd.read)['scheduling']
      rd.close

      unless scheduling
        message = "Scheduling didn't complete. Please check passed params to it"
        SlackNotificationJob.perform_now(iteration, 'crontab', message)
        return
      end

      iteration.update!(export: false, current_account: account)
      ExportJob.perform_now(iteration, account)
    end
  end
end
