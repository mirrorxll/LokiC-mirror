# frozen_string_literal: true

class SamplesAndAutoFeedbackJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, options = {})
    Process.wait(
      fork do
        status = true
        message = "Success. FCD's samples have been created"
        staging_table = iteration.story_type.staging_table
        sample_args = nil

        ids =
          if options[:cron]
            Table.select_edge_ids(staging_table.name, [:id])
          else
            column_names = staging_table.columns.ids_to_names(options[:columns])
            sample_args = { columns: column_names, ids: options[:row_ids] }
            edge_ids = Table.select_edge_ids(staging_table.name, column_names)
            row_ids = options[:row_ids].delete(' ').split(',')
            edge_ids + row_ids
          end

        MiniLokiC::Code.execute(iteration, :creation, sampled: true, ids: ids.join(','))
        iteration.samples.where(staging_row_id: ids).update_all(sampled: true)

        Samples.auto_feedback(iteration.story_type, true)

        iteration.update(story_sample_args: sample_args)
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        iteration.update(story_samples: status)
        send_to_action_cable(iteration, :samples, message)
      end
    )

    iteration.reload.story_samples
  end
end
