class ExecuteCronTabJob < ApplicationJob
  queue_as :default

  def perform(story_type_id)
    puts story_type = StoryType.find(story_type_id).name

    # iteration = story_type.iterations.create(name: "cron_tab_#{DateTime.now.strftime('%Y%m%d%H%M')}")
    #
    # story_type.update(current_iteration: iteration)
    # story_type.staging_table.default_iter_id
    #
    # PopulationJob.perform_now(iteration, story_type.cron_tab.population_params)
    # ExportConfigurationsJob.perform_now(iteration)
    # SamplesAndAutoFeedbackJob.perform_now(iteration, 'TO DOOOOO')
    # CreationJob.perform_now(iteration)
    # ExportJob.perform_now(iteration)
  end
end
