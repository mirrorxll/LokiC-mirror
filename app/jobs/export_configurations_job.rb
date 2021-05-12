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
    message = 'Success. Export configurations created'
    exp_config_counts = {}
    exp_config_counts.default = 0
    iteration = story_type.iteration

    st_cl_pub_tgs = sort_client_publication_tag(story_type.clients_publications_tags)

    story_type.staging_table.publication_ids.each do |pub_id|
      publication = Publication.find_by(pl_identifier: pub_id)
      cl_pub_tg = st_client_publication_tag(st_cl_pub_tgs, publication)
      next if publication.nil? || cl_pub_tg.nil?

      exp_c = ExportConfiguration.find_or_initialize_by(
        story_type: story_type,
        publication: publication
      )

      exp_c.photo_bucket = story_type.photo_bucket
      exp_c.tag = (cl_pub_tg.tag && publication.tag?(cl_pub_tg.tag) ? cl_pub_tg.tag : nil)
      exp_c.save!
    end

  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update(creating_export_configurations: status)

    if manual
      send_to_action_cable(story_type.iteration, :properties, message)
      send_to_dev_slack(iteration, 'EXPORT CONFIGURATIONS', message)
    end
  end

  def sort_client_publication_tag(st_cl_pub_tgs)
    st_cl_pub_tgs = st_cl_pub_tgs.sort_by { |el| el.publication ? el.publication.id : 0 }.reverse # pop st_cl_pub_tgs with pubs
    st_cl_pub_tgs.each_with_index do |st_cl_pub_tg, index|
      if st_cl_pub_tg.publication.nil? && (st_cl_pub_tg.client.name == 'Metric Media' || st_cl_pub_tg.client.name == 'Metro Business Network')
        st_cl_pub_tgs.insert(st_cl_pub_tgs.count - 1, st_cl_pub_tgs.delete_at(index))
      end
    end
  end

  def st_client_publication_tag(clients_publications_tags, publication)
    all_mm_pubs = Publication.all_mm_publications

    clients_publications_tags.to_a.find do |client_publication_tag|
      client = client_publication_tag.client
      publications =
        if client.name.eql?('Metric Media')
          all_mm_pubs
        else
          client.publications
        end

      client_publication_tag.publication.nil? ? publications.exists?(publication.id) : client_publication_tag.publication == publication
    end
  end
end
