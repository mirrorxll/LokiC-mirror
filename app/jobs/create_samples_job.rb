# frozen_string_literal: true

class CreateSamplesJob < ApplicationJob
  queue_as :default

  def perform(staging_table, params)
    row_ids = params[:row_ids].delete(' ').split(',')
    column_names = staging_table.columns.ids_to_names(params[:columns])
    edge_ids = Table.select_edge_ids(staging_table.name, column_names)

    ids = row_ids + edge_ids
    MiniLokiC::Code.execute(staging_table.story_type, :creation, ids: ids)
  end
end
