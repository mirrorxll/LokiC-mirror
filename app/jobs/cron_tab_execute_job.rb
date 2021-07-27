# frozen_string_literal: true

class CronTabExecuteJob < ApplicationJob
  queue_as :cron_tab

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    cron_tab = story_type.cron_tab
    return if cron_tab.freeze_execution

    old_iteration = story_type.iteration
    new_iteration = story_type.iterations.create(name: DateTime.now.strftime('CT%Y%m%d'))

    story_type.update(current_iteration: new_iteration)
    story_type.staging_table.default_iter_id

    new_iteration.update!(population: false, population_args: cron_tab.population_params)
    raise StandardError unless PopulationJob.perform_now(new_iteration, population_args: cron_tab.population_params)

    new_iteration.update!(story_samples: false)
    raise StandardError unless SamplesAndAutoFeedbackJob.perform_now(new_iteration, cron: true)

    new_iteration.update!(creation: false)
    raise StandardError unless CreationJob.perform_now(new_iteration)

    new_iteration = story_type.iteration
    new_iteration.update!(export: false)
    raise StandardError unless ExportJob.perform_now(new_iteration)

  rescue StandardError => e
    iter =
      if new_iteration.population.nil?
        story_type.update(current_iteration: old_iteration)
        new_iteration.destroy
        "*NEW ITERATION DIDN'T CREATE*  "
      else
        ''
      end

    message = "[ CronTabExecutionError ] -> #{iter}#{e.message} at #{e.backtrace.first}".gsub('`', "'")
    send_to_dev_slack(new_iteration, 'CRONTAB', message)
  end
end
