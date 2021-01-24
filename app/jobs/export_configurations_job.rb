# frozen_string_literal: true

class ExportConfigurationsJob < ApplicationJob
  queue_as :export_configurations

  def perform(iteration)
    Process.wait(
      fork do
        status = true
        message = 'SUCCESS'
        exp_config_counts = {}
        exp_config_counts.default = 0
        st_cl_tgs = iteration.story_type.client_tags

        iteration.story_type.staging_table.publication_ids.each do |pub_id|
          publication = Publication.find_by(pl_identifier: pub_id)
          cl_tg = st_client_tag(st_cl_tgs, publication)
          next if publication.nil? || cl_tg.nil?

          create_update_export_config(iteration.story_type, publication, cl_tg.tag)
          exp_config_counts[cl_tg.client.name] += 1
        end

        iteration.update(export_configuration_counts: exp_config_counts)
      rescue StandardError => e
        status = nil
        message = e
      ensure
        iteration.reload.update(export_configurations: status)
        send_to_action_cable(iteration, export_configurations_msg: status)
        send_to_slack(iteration, 'EXPORT CONFIGURATIONS', message)
      end
    )
  end

  private

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

  def create_update_export_config(story_type, publication, tag)
    exp_c = ExportConfiguration.find_or_initialize_by(
      story_type: story_type,
      publication: publication
    )

    exp_c.photo_bucket = story_type.photo_bucket
    exp_c.tag = (tag && publication.tag?(tag) ? tag : nil)
    exp_c.save!
  end
end
