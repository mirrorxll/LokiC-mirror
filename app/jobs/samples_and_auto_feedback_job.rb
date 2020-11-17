# frozen_string_literal: true

class SamplesAndAutoFeedbackJob < ApplicationJob
  queue_as :samples

  def perform(story_type, params)
    staging_table = story_type.staging_table
    column_names = staging_table.columns.ids_to_names(params[:columns])
    sample_args = { columns: column_names, ids: params[:row_ids] }
    edge_ids = Table.select_edge_ids(staging_table.name, column_names)
    row_ids = params[:row_ids].delete(' ').split(',')
    ids = (edge_ids + row_ids)

    MiniLokiC::Code.execute(story_type, :creation, sampled: true, ids: ids.join(','))
    story_type.iteration.samples.where(staging_row_id: ids, sampled: false).update_all(sampled: true)

    Samples.auto_feedback(story_type)
    status = true
    message = 'samples created.'
  rescue StandardError => e
    sample_args = status = nil
    message = e.message
  ensure
    story_type.iteration.update(story_samples: status, story_sample_args: sample_args)
    send_to_action_cable(story_type, samples_msg: message)
    send_to_slack(story_type, message)
  end
end
