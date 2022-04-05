# frozen_string_literal: true

class ClientsPublicationsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
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
  end
end
