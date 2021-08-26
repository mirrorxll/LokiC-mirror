# frozen_string_literal: true

module StoryTypes
  class CronTabJob < StoryTypeJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      cron_tab = story_type.cron_tab
      return if cron_tab.freeze_execution

      account = story_type.developer
      new_iteration = story_type.iterations.create!(name: DateTime.now.strftime('CT%Y%m%d'), current_account: account)

      story_type.update!(current_iteration: new_iteration, current_account: account)
      story_type.staging_table.default_iter_id

      new_iteration.update!(population: false, population_args: cron_tab.population_params, current_account: account)
      return unless PopulationJob.perform_now(new_iteration, account, population_args: cron_tab.population_params)

      new_iteration.update!(samples: false, current_account: account)
      return unless SamplesAndAutoFeedbackJob.perform_now(new_iteration, account, cron: true)

      new_iteration.update!(creation: false, current_account: account)
      return unless CreationJob.perform_now(new_iteration, account)

      new_iteration = story_type.iteration
      new_iteration.update!(export: false, current_account: account)
      ExportJob.perform_now(new_iteration, account)
    end
  end
end
