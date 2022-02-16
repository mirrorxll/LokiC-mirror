# frozen_string_literal: true

class ClientsPublicationsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        pubs_ids_statewide = MiniLokiC::Population::Publications.all_state_lvl.map { |pub| pub['id'] }
        clients_pubs_tags = PipelineReplica[:production].get_clients_publications_tags
        clients_pubs_tags.reject! { |row| row['client_name'].eql?('Metric Media') }

        Client.find_or_create_by(name: 'Metric Media').touch

        clients_pubs_tags.flatten.each do |cpt|
          site_url = cpt['site_url']

          client = Client.find_or_create_by(pl_identifier: cpt['client_id'])
          client.update(name: cpt['client_name'])
          client.touch

          next if cpt['publication_name'].nil?

          publication = client.publications.find_or_initialize_by(pl_identifier: cpt['publication_id'])
          publication.update(
            name: cpt['publication_name'],
            home_page: (site_url&.end_with?('/') ? site_url[0...-1] : site_url),
            statewide: pubs_ids_statewide.include?(publication.pl_identifier)
          )
          publication.touch

          next if cpt['publication_tags'].nil?

          tags = cpt['publication_tags'].split(':::').map { |tag| [tag.split('::')].to_h }
          tags.reduce(:merge).each do |id, name|
            tag = Tag.find_or_create_by(pl_identifier: id)
            tag.update(name: name)
            tag.touch
            next if publication.tags.exists?(tag.id)

            publication.tags << tag
          end
        end

        categories_all = Client.find_or_create_by(name: 'Client for categories all')
        ['all local publications', 'all statewide publications', 'all publications'].each do |name|
          Publication.find_or_create_by(name: name, client: categories_all).touch
        end
        categories_all.touch

        blank_tag = Tag.find_or_create_by(name: '_Blank')
        Client.all.each do |c|
          c.tags << blank_tag unless c.tags.exists?(blank_tag.id)

          c.publications.each do |p|
            p.tags << blank_tag unless c.tags.exists?(blank_tag.id)
          end
        end
        blank_tag.touch

        delete_broken_clients
        delete_broken_publications
        delete_broken_tags
      end
    )
  end

  private

  def client_delete_msg(client)
    "*Client #{client.name} (PL ID -> #{client.pl_identifier})* was removed from LokiC DB. "\
    'Check it and mark this message please. Thanks!'
  end

  def publication_delete_msg(publication)
    "*Publication #{publication.name} (PL ID -> #{publication.pl_identifier}, "\
    "client -> #{publication.client&.name || 'client not find'})* "\
    'was removed from LokiC DB. Check it and mark this message please. Thanks!'
  end

  def tag_delete_msg(tag)
    "*Tag #{tag.name} (PL ID -> #{tag.pl_identifier})* was removed from LokiC DB. "\
    'Check it and mark this message please. Thanks!'
  end

  def ds_prop_delete_msg(data_set)
    "*<#{generate_url(data_set)} | Data Set ##{data_set.id}>*\n>"\
    "Default Data Set's property was removed. Check it and mark this message please. Thanks!"
  end

  def st_prop_delete_msg(story_type)
    "*<#{generate_url(story_type)} | Story Type ##{story_type.id}>*\n>"\
    "Story Type's property was removed. Check it and mark this message please. Thanks!"
  end

  def tag_ds_prop_delete_msg(ds_cpt)
    "*<#{generate_url(ds_cpt.data_set)} | Data Set ##{ds_cpt.data_set.id}>*\n>"\
    'Tag for default property was removed. Check it and mark this message please. Thanks!'
  end

  def tag_st_prop_delete_msg(st_cpt)
    "*<#{generate_url(st_cpt.story_type)} | Story Type ##{st_cpt.story_type.id}>*\n>"\
    "Tag for *#{st_cpt.client&.name || '(Client not find)'}* property was removed. "\
    'Check it and mark this message please. Thanks!'

  end

  def delete_broken_clients
    Client.where('DATE(updated_at) < CURRENT_DATE() AND exist_in_pl = 1').each do |client|
      SlackNotificationJob.perform_now('lokic_alerts', client_delete_msg(client))

      DataSetClientPublicationTag.where(client: client).each do |ds_cpt|
        ds_cpt.destroy
        SlackNotificationJob.perform_now('lokic_alerts', ds_prop_delete_msg(ds_cpt.data_set))
      end

      StoryTypeClientPublicationTag.where(client: client).each do |st_cpt|
        st_cpt.destroy
        SlackNotificationJob.perform_now('lokic_alerts', st_prop_delete_msg(st_cpt.story_type))
      end

      client.destroy
    end
  end

  def delete_broken_publications
    Publication.where('DATE(updated_at) < CURRENT_DATE()').each do |publication|
      SlackNotificationJob.perform_now('lokic_alerts', publication_delete_msg(publication))

      DataSetClientPublicationTag.where(publication: publication).each do |ds_cpt|
        ds_cpt.destroy
        SlackNotificationJob.perform_now('lokic_alerts', ds_prop_delete_msg(ds_cpt.data_set))
      end

      StoryTypeClientPublicationTag.where(publication: publication).each do |st_cpt|
        st_cpt.destroy
        SlackNotificationJob.perform_now('lokic_alerts', st_prop_delete_msg(st_cpt.story_type))
      end

      publication.destroy
    end
  end

  def delete_broken_tags
    Tag.where('DATE(updated_at) < CURRENT_DATE()').each do |tag|
      SlackNotificationJob.perform_now('lokic_alerts', tag_delete_msg(tag))

      DataSetClientPublicationTag.where(tag: tag).each do |ds_cpt|
        ds_cpt.update(tag: nil)
        SlackNotificationJob.perform_now('lokic_alerts', tag_ds_prop_delete_msg(ds_cpt))
      end

      StoryTypeClientPublicationTag.where(tag: tag).each do |st_cpt|
        st_cpt.update(tag: nil)
        SlackNotificationJob.perform_now('lokic_alerts', tag_st_prop_delete_msg(st_cpt))
      end

      tag.destroy
    end
  end
end
