# frozen_string_literal: true

class CronTabExecuteJob < ApplicationJob
  queue_as :cron_tab

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    cron_tab = story_type.cron_tab
    return if cron_tab.freeze_execution

    iteration = story_type.iterations.create(name: DateTime.now.strftime('CT%Y%m%d'))
    story_type.update(current_iteration: iteration)
    story_type.staging_table.default_iter_id

    iteration.update(population: false, population_args: cron_tab.population_params)
    raise StandardError unless PopulationJob.perform_now(iteration, population_args: cron_tab.population_params)

    iteration.update(story_samples: false)
    raise StandardError unless SamplesAndAutoFeedbackJob.perform_now(iteration, cron: true)

    iteration.update(creation: false)
    raise StandardError unless CreationJob.perform_now(iteration)

    iteration.update(export: false)
    raise StandardError unless ExportJob.perform_now(iteration)
  rescue StandardError
    message = 'Something went wrong. Please, check messages above'
    send_to_dev_slack(iteration, 'CRONTAB', message)
  end
end
