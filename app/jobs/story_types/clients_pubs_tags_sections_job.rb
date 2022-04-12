# frozen_string_literal: true

module StoryTypes
  class ClientsPubsTagsSectionsJob < ApplicationJob
    sidekiq_options queue: :cron_tab

    def perform(*_args)
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

      Client.all.each do |client|
        tags = client.publications.to_a.flat_map { |pub| pub.tags.to_a }.uniq

        tags.each do |tag|
          if !client.tags.exists?(tag.id)
            client.tags << tag
          else
            ClientTag.find_by(client: client, tag: tag)&.touch
          end
        end
      end

      mm_generic = Client.find_by(name: 'Metric Media')
      mm_by_state = Client.where('name LIKE :query', query: 'MM -%').to_a

      mm_by_state.each do |mm_state|
        mm_state.tags.each do |tag|
          if !mm_generic.tags.exists?(tag.id)
            mm_generic.tags << tag
          else
            ClientTag.find_by(client: mm_state, tag: tag)&.touch
          end
        end
      end

      ClientTag.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      ClientTag.all.each do |ct|
        ct.delete and next if ct.client.nil? || ct.tag.nil?

        update_tag_for_pubs(ct, mm_by_state)
      end

      PipelineReplica[:production].get_sections.each do |raw_section|
        section = Section.find_or_initialize_by(pl_identifier: raw_section['id'])
        section.name = raw_section['name']
        section.save!
        section.touch

        section_to_clients(section)
      end

      Section.where('DATE(updated_at) < DATE(created_at)').delete_all
    end

    private

    def update_tag_for_pubs(ct, mm_by_state)
      client = ct.client.name.eql?('Metric Media') ? mm_by_state : ct.client
      all = ct.client.publications
      local = ct.client.local_publications
      statewide = ct.client.statewide_publications

      if ct.client.name.eql?('LGIS')
        query = 'SELECT id FROM communities where client_company_id = 91 and site_matomo_enabled = 1;'
        pl_ids_lgis_pubs = PipelineReplica[:production].pl_replica.query(query).map { |p| p['id'] }
        for_all_pubs = all.where(pl_identifier: pl_ids_lgis_pubs) - all.where(client: client, pl_identifier: pl_ids_lgis_pubs) == []
        for_local_pubs = local.where(pl_identifier: pl_ids_lgis_pubs) - all.where(client: client, statewide: false, pl_identifier: pl_ids_lgis_pubs) == []
        for_statewide_pubs = statewide.where(pl_identifier: pl_ids_lgis_pubs) - all.where(client: client, statewide: true, pl_identifier: pl_ids_lgis_pubs) == []
      else
        for_all_pubs = all - all.where(client: client) == []
        for_local_pubs = local - all.where(client: client, statewide: false) == []
        for_statewide_pubs = statewide - all.where(client: client, statewide: true) == []
      end

      ct.update!(
        for_all_pubs: for_all_pubs,
        for_local_pubs: for_local_pubs,
        for_statewide_pubs: for_statewide_pubs
      )

      ct.touch
    end

    def section_to_clients(section)
      return unless [2, 16].include?(section.pl_identifier)

      where = section.pl_identifier.eql?(2) ? "name = 'LGIS'" : '1 = 1'

      Client.where(where).each do |client|
        client.sections << section unless client.sections.exists?(section.id)
      end
    end
  end
end
