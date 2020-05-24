# frozen_string_literal: true

class SamplesJob < ApplicationJob
  queue_as :samples

  def perform(story_type, params)
    staging_table = story_type.staging_table
    column_names = staging_table.columns.ids_to_names(params[:columns])
    edge_ids = Table.select_edge_ids(staging_table.name, column_names)
    row_ids = params[:row_ids].delete(' ').split(',')
    ids = (edge_ids + row_ids).join(',')

    MiniLokiC::Code.execute(story_type, :creation, sampled: true, ids: ids)
    status = true
    message = 'samples created.'
  rescue StandardError => e
    puts e
    status = nil
    message = e
    ids = nil
  ensure
    story_type.update_iteration(story_samples: status, story_sample_ids: ids)
    send_status(story_type, samples_message: message)
  end
end
