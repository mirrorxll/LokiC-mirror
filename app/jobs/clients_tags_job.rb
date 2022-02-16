# frozen_string_literal: true

class ClientsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
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

          update_tags_for_pubs(ct, mm_by_state)
        end
      end
    )
  end

  private

  def attach_tags_to(client)
  end

  def attach_tags_to_mm_generic(mm_state, mm_generic)
  end

  def update_tags_for_pubs(ct, mm_by_state)
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

    ct.update!(for_all_pubs: for_all_pubs, for_local_pubs: for_local_pubs, for_statewide_pubs: for_statewide_pubs)
    ct.touch
  end
end
