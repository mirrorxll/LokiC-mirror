# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(story_type)
    st_cl_tgs = story_type.client_tags

    story_type.staging_table.publication_ids.each do |p_id|
      publication = Publication.find_by(pl_identifier: p_id)
      cl_t = st_cl_tgs.find_by(client: publication.client)
      next if publication.nil? || cl_t.nil?

      create_export_config(story_type, publication, cl_t.tag)
    end

    status = true
    message = 'export configurations created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export_configurations: status)
    send_status(story_type, export_configurations_message: message)
  end

  private

  def create_export_config(story_type, publication, tag)
    ExportConfiguration.create(
      story_type: story_type,
      publication: publication,
      tag: (publication.tag?(tag) ? tag : nil)
    )
  end
end
