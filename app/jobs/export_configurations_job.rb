# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(story_type)
    story_type.staging_table.clients_publications.each do |row|
      row[:publication_ids].each do |pub_id|
        create_export_config(story_type, row[:client_id], pub_id)
      end
    end
  end

  private

  def create_export_config(story_type, client_id, pub_id)
    ExportConfiguration.create!(
      story_type: story_type,
      client_id: client_id,
      publication_id: pub_id
    )
  end
end
