# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(story_type)
    story_type.staging_table.publications.each do |pub_id|
      create_export_config(story_type, pub_id)
    end
  end

  private

  def create_export_config(story_type, pub_id)
    ExportConfiguration.create(
      story_type: story_type,
      publication_id: pub_id
    )
  end
end
