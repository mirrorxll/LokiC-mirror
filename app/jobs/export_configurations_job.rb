# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(story_type)
    st_cl_tgs = story_type.client_tags

    story_type.staging_table.publication_ids.each do |p_id|
      publication = Publication.find_by(pl_identifier: p_id)
      cl_tg = st_client_tag(st_cl_tgs, publication)
      next if publication.nil? || cl_tg.nil?

      create_update_export_config(story_type, publication, cl_tg.tag)
    end

    status = true
    message = 'export configurations created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export_configurations: status)
    send_to_action_cable(story_type, export_configurations_msg: status)
    send_to_slack(story_type, message)
  end

  private

  def st_client_tag(clients_tags, publication)
    clients_tags.to_a.find do |client_tag|
      client_tag.client.publications.exists?(publication.id)
    end
  end

  def create_update_export_config(story_type, publication, tag)
    exp_c = ExportConfiguration.find_or_create_by(
      story_type: story_type,
      publication: publication,
      photo_bucket: story_type.photo_bucket
    )

    exp_c.tag = (tag && publication.tag?(tag) ? tag : nil)
    exp_c.save!
  end
end
