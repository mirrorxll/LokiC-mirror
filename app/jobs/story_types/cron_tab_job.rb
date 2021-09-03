# frozen_string_literal: true

module StoryTypes
  class CronTabJob < StoryTypesJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      cron_tab = story_type.cron_tab
      return if cron_tab.freeze_execution

      account = Account.find_by(email: 'main@lokic.loc')
      iteration = story_type.cron_tab_iteration || story_type.create_cron_tab_iteration!
      staging_table = story_type.staging_table

      staging_table.default_iter_id(iteration.id)
      iteration.update!(population: false, population_args: cron_tab.population_params, current_account: account)
      PopulationJob.perform_now(iteration, account, population_args: cron_tab.population_params)

      unless Table.rows_present?(staging_table.name, iteration.id)
        message = "Population didn't add new rows to staging table"
        SlackNotificationJob.perform_now(iteration, 'crontab', message, account)
        return
      end

      story_type.update!(current_iteration: iteration, current_account: account)
      iteration.update!(name: DateTime.now.strftime('CT%Y%m%d')) if iteration.name.blank?

      iteration.update!(samples: false, current_account: account)
      return unless SamplesAndAutoFeedbackJob.perform_now(iteration, account, cron: true)

      iteration.update!(creation: false, current_account: account)
      return unless CreationJob.perform_now(iteration, account)

      iteration = story_type.iteration
      iteration.update!(export: false, current_account: account)
      ExportJob.perform_now(iteration, account)
    end
  end
end
