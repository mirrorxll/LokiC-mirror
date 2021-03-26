# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :story_type

  def perform(story_type, manual = false)
    if manual
      pid = fork { create_update_export_config(story_type, manual) }
      Process.wait(pid)
    else
      create_update_export_config(story_type, manual)
    end
  end

  private

  def create_update_export_config(story_type, manual)
    status = true
    message = 'Success'
    exp_config_counts = {}
    exp_config_counts.default = 0
    iteration = story_type.iteration
    st_cl_tgs = story_type.client_tags

    story_type.staging_table.publication_ids.each do |pub_id|
      publication = Publication.find_by(pl_identifier: pub_id)
      cl_tg = st_client_tag(st_cl_tgs, publication)
      next if publication.nil? || cl_tg.nil?

      exp_c = ExportConfiguration.find_or_initialize_by(
        story_type: story_type,
        publication: publication
      )

      exp_c.photo_bucket = story_type.photo_bucket
      exp_c.tag = (cl_tg.tag && publication.tag?(cl_tg.tag) ? cl_tg.tag : nil)
      exp_c.save!
    end

  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update(creating_export_configurations: status)

    send_to_slack(iteration, 'EXPORT CONFIGURATIONS', message) if manual
  end

  def st_client_tag(clients_tags, publication)
    all_mm_pubs = Client.all_mm_publications

    clients_tags.to_a.find do |client_tag|
      client = client_tag.client
      publications =
        if client.name.eql?('Metric Media')
          all_mm_pubs
        else
          client.publications
        end

      publications.exists?(publication.id)
    end
  end
end
