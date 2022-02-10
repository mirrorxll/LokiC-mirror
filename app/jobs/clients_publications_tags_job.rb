# frozen_string_literal: true

class ClientsPublicationsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        clients_pubs_tags = PipelineReplica[:production].get_clients_publications_tags
        clients_pubs_tags.reject! { |row| row['client_name'].eql?('Metric Media') }

        pubs_ids_statewide = pubs_pl_ids_statewide

        clients_pubs_tags.flatten.each do |cl_pub_tags|
          client = update_client(cl_pub_tags)
          next if cl_pub_tags['publication_name'].nil?

          publication = update_publication(client, cl_pub_tags, pubs_ids_statewide)
          update_tags(publication, cl_pub_tags)
        end

        mm_gen = Client.find_or_initialize_by(name: 'Metric Media')
        mm_gen.save!
        mm_gen.touch

        categories_all = Client.find_or_initialize_by(name: 'Client for categories all')
        categories_all.save!
        categories_all.touch

        blank_tag = Tag.find_or_initialize_by(name: '_Blank')
        blank_tag.save!
        blank_tag.touch

        ['all local publications', 'all statewide publications', 'all publications'].each do |name|
          pub = Publication.find_or_initialize_by(name: name)
          pub.client = categories_all
          pub.save!
          pub.touch
        end

        Client.all.each do |c|
          next if c.tags.exists?(blank_tag.id)

          c.tags << blank_tag
          c.publications.each { |p| p.tags << blank_tag }
        end

        Client.where('DATE(updated_at) < CURRENT_DATE() AND exist_in_pl = 1').destroy_all
        Publication.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
        Tag.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
      end
    )
  end

  private

  def update_client(cl_pub_tags)
    client = Client.find_or_initialize_by(pl_identifier: cl_pub_tags['client_id'])
    client_name = cl_pub_tags['client_name']
    client.name = client_name
    client.save!
    client.touch

    client
  end

  def update_publication(client, cl_pub_tags, pubs_ids_statewide)
    pub = client.publications.find_or_initialize_by(pl_identifier: cl_pub_tags['publication_id'])
    pub.name = cl_pub_tags['publication_name']
    pub.home_page = drop_ends_slash(cl_pub_tags['site_url'])
    pub.statewide = pubs_ids_statewide.include? pub.pl_identifier
    pub.save!
    pub.touch

    pub
  end

  def pubs_pl_ids_statewide
    MiniLokiC::Population::Publications.all_state_lvl.map { |pub| pub['id'] }
  end

  def drop_ends_slash(url)
    return if url.blank?

    url.end_with?('/') ? url[0...-1] : url
  end

  def update_tags(publication, cl_pub_tags)
    return if cl_pub_tags['tags'].nil?

    tags = cl_pub_tags['tags'].split(':::').map { |tag| [tag.split('::')].to_h }
    tags.reduce(:merge).each do |id, name|
      tag = Tag.find_or_initialize_by(pl_identifier: id)
      tag.name = name
      tag.save!
      tag.touch

      next if publication.tags.exists?(tag.id)

      publication.tags << tag
    end
  end
end
