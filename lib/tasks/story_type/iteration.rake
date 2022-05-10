# frozen_string_literal: true

namespace :story_type do
  namespace :iteration do
    desc 'Execute story type production process'
    task execute: :environment do
      StoryTypes::Iterations::CronTabTask.new.perform(ENV['story_type_id'])
    end

    desc "Execute story type iteration's population"
    task population: :environment do
      options = JSON.parse(ENV['options'])

      StoryTypes::Iterations::PopulationTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id'],
        options
      )
    end

    desc "Create story type iteration's FCD samples"
    task samples_and_auto_feedback: :environment do
      options = JSON.parse(ENV['options'])

      StoryTypes::Iterations::SamplesAndAutoFeedbackTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id'],
        options
      )
    end

    desc "Purge story type iteration's FCD samples"
    task purge_samples_and_auto_feedback: :environment do
      StoryTypes::Iterations::PurgeSamplesTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id']
      )
    end

    desc "Execute story type iteration's creation"
    task creation: :environment do
      StoryTypes::Iterations::CreationTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id']
      )
    end

    desc "Purge story type iteration's created stories"
    task purge_creation: :environment do
      StoryTypes::Iterations::PurgeCreationTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id']
      )
    end

    desc "Execute story type iteration's scheduling"
    task scheduling: :environment do
      options = JSON.parse(ENV['options'])

      StoryTypes::Iterations::SchedulerTask.new.perform(
        ENV['iteration_id'],
        ENV['type'],
        options
      )
    end

    desc "Execute story type iteration's export"
    task export: :environment do
      StoryTypes::Iterations::ExportTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id'],
        { url: ENV['url'] }
      )
    end

    desc "Purge story type iteration's export"
    task purge_export: :environment do
      StoryTypes::Iterations::PurgeExportTask.new.perform(
        ENV['iteration_id'],
        ENV['account_id']
      )
    end
  end
end
