# frozen_string_literal: true

class CronTabExecuteJob < ApplicationJob
  queue_as :cron_tab

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    cron_tab = story_type.cron_tab
    return if cron_tab.freeze_execution

    iteration = story_type.iterations.create(name: DateTime.now.strftime('%Y:%m:%d:%H:%M'))
    story_type.update(current_iteration: iteration)
    story_type.staging_table.default_iter_id

    raise RuntimeError unless PopulationJob.perform_now(iteration, cron_tab.population_params)
    raise RuntimeError unless ExportConfigurationsJob.perform_now(iteration)
    raise RuntimeError unless SamplesAndAutoFeedbackJob.perform_now(iteration, cron: true)
    raise RuntimeError unless CreationJob.perform_now(iteration)
    raise RuntimeError unless ExportJob.perform_now(iteration)
  rescue StandardError
    false
  end
end
