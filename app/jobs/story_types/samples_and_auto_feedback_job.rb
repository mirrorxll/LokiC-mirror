# frozen_string_literal: true

module StoryTypes
  class SamplesAndAutoFeedbackJob < StoryTypesJob
    def perform(iteration, account, options = {})
      status = true
      story_type = iteration.story_type
      story_type.sidekiq_break.update!(cancel: false)
      sample_args = {}
      staging_table = iteration.story_type.staging_table
      publication_ids = iteration.story_type.publication_pl_ids

      options[:iteration] = iteration
      options[:publication_ids] = publication_ids
      options[:sampled] = true

      ids =
        if options[:cron]
          Table.select_edge_ids(staging_table.name, [:id], *publication_ids)
        else
          column_names = staging_table.columns.ids_to_names(options[:columns])
          sample_args = { columns: column_names, ids: options[:row_ids] }
          edge_ids = Table.select_edge_ids(staging_table.name, column_names, *publication_ids)
          row_ids = options[:row_ids].delete(' ').split(',')
          edge_ids + row_ids
        end

      iteration.update!(sample_args: sample_args, current_account: account)

      sampled_before = iteration.stories.where(sampled: true).count

      options = options.merge({ ids: ids.join(','), type: 'story' })
      MiniLokiC::StoryTypeCode[iteration.story_type].execute(:creation, options)
      Samples.auto_feedback(iteration, options[:cron])

      iteration.stories.where(staging_row_id: ids).update_all(sampled: true)

      sampled_after = iteration.stories.where(sampled: true).count
      message =
        if sampled_before.eql?(sampled_after)
          "New samples haven't been created by passed params. Check it!"
        else
          'Success. Samples have been created'
        end


      if story_type.sidekiq_break.reload.cancel
        status = nil
        message = 'Canceled'
      end

      false
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
      true
    ensure
      iteration.update!(samples: status, current_account: account)
      story_type.sidekiq_break.update!(cancel: false)
      send_to_action_cable(story_type, :samples, message)

      StoryTypes::SlackNotificationJob.perform_now(iteration, 'samples', message) if options[:cron] && status.nil?
    end
  end
end
