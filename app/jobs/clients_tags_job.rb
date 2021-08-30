# frozen_string_literal: true

class ClientsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        Client.all.each { |cl| attach_tags_to(cl) }

        mm_generic = Client.find_by(name: 'Metric Media')
        mm_by_state = Client.where('name LIKE :query', query: 'MM -%').to_a
        attach_tags_to_mm_generic(mm_generic, mm_by_state)
        ClientTag.all.each { |ct| update_tags_for_pubs(ct, mm_by_state) }
      end
    )
  end

  private

  def update_tags_for_pubs(ct, mm_by_state)
    client = ct.client.name == 'Metric Media' ? mm_by_state : ct.client

    if ct.client.name == 'LGIS'
      pl_ids_lgis_pubs = actual_pl_ids_lgis_pubs
      ct.update!(for_all_pubs: ct.client.publications.where(pl_identifier: pl_ids_lgis_pubs) - ct.tag.publications.where(client: client, pl_identifier: pl_ids_lgis_pubs) == [],
                 for_local_pubs: ct.client.local_publications.where(pl_identifier: pl_ids_lgis_pubs) - ct.tag.publications.where(client: client, statewide: false, pl_identifier: pl_ids_lgis_pubs) == [],
                 for_statewide_pubs: ct.client.statewide_publications.where(pl_identifier: pl_ids_lgis_pubs) - ct.tag.publications.where(client: client, statewide: true, pl_identifier: pl_ids_lgis_pubs) == [])
    else
      ct.update!(for_all_pubs: ct.client.publications - ct.tag.publications.where(client: client) == [],
                 for_local_pubs: ct.client.local_publications - ct.tag.publications.where(client: client, statewide: false) == [],
                 for_statewide_pubs: ct.client.statewide_publications - ct.tag.publications.where(client: client, statewide: true) == [])
    end
  end

  def attach_tags_to(client)
    tags = client.publications.to_a.map { |pub| pub.tags.to_a }
    tags.flatten.uniq.each { |t| client.tags << t unless client.tags.exists?(t.id) }
  end

  def attach_tags_to_mm_generic(mm_generic, mm_by_state)
    mm_by_state.each do |cl|
      cl.tags.each { |t| mm_generic.tags << t unless mm_generic.tags.exists?(t.id) }
    end
  end

  def actual_pl_ids_lgis_pubs
    PipelineReplica[:production].pl_replica.query('SELECT id FROM communities where client_company_id = 91 and site_matomo_enabled = 1;').map { |pub| pub['id'] }
  end
end
