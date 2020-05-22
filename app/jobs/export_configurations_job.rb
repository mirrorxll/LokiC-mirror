# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(story_type)
    publication_ids = story_type.staging_table.publication_ids
    publication_ids.each { |p_id| create_export_config(story_type, p_id) }

    status = true
    message = 'export configurations created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export_configurations: status)
    send_status(story_type, export_configurations: message)
  end

  private

  def create_export_config(story_type, pub_id)
    publication = Publication.find_by(pl_identifier: pub_id)

    ExportConfiguration.create!(
      story_type: story_type,
      publication: publication
    )
  end
end
