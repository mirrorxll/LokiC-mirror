# frozen_string_literal: true

class SamplesJob < ApplicationJob
  queue_as :create_samples

  def perform(staging_table, params)
    column_names = staging_table.columns.ids_to_names(params[:columns])
    edge_ids = Table.select_edge_ids(staging_table.name, column_names)
    row_ids = params[:row_ids].delete(' ').split(',')
    ids = edge_ids + row_ids

    MiniLokiC::Code.execute(staging_table.story_type, :creation, ids: ids)
    status = true
    message = 'samples created.'
  rescue StandardError => e
    status = nil
    message = e
    ids = nil
  ensure
    story_type.update_iteration(samples: status, sample_ids: ids)
    send_status(story_type, message)
  end
end
