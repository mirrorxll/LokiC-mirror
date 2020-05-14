# frozen_string_literal: true

class CreateSamplesJob < ApplicationJob
  queue_as :default

  def perform(staging_table, params)
    ids = params[:row_ids].delete(' ').split(',')
    column_names = staging_table.columns.ids_to_names(params[:columns])
    edge_ids = Table.select_edge_ids(staging_table.name, column_names)

    MiniLokiC::Code.execute(staging_table.story_type, :creation, ids: ids + edge_ids)
  end
end
