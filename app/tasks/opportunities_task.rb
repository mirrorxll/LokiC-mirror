# frozen_string_literal: true

class OpportunitiesTask < ApplicationTask
  def perform(*_args)
    replica = PipelineReplica[:production]

    agency_ids = []
    replica.get_agencies.each do |row|
      agency = Agency.find_or_create_by!(id: row['id'])
      agency.update!(name: row['name'], partner: row['partner'])
      agency_ids << row['id']
    end
    Agency.where.not(id: agency_ids).destroy_all

    opportunity_ids = []
    replica.get_opportunities.each do |row|
      opportunity = Opportunity.find_or_create_by!(id: row['id'])
      opportunity.update!(
        name: row['name'],
        archived_at: row['archived_at'],
        agency_id: row['agency_id']
      )
      opportunity_ids << row['id']
    end
    Opportunity.where.not(id: opportunity_ids).destroy_all

    opportunity_type_ids = []
    replica.get_opportunity_types.each do |row|
      opportunity_type = OpportunityType.find_or_create_by!(id: row['id'])
      opportunity_type.update!(name: row['name'])
      opportunity_type_ids << row['id']
    end
    OpportunityType.where.not(id: opportunity_type_ids).destroy_all

    content_type_ids = []
    replica.get_content_types.each do |row|
      content_type = ContentType.find_or_create_by!(id: row['id'])
      content_type.update!(
        name: row['name'],
        archived_at: row['archived_at'],
        content_group_id: row['content_group_id']
      )
      content_type_ids << row['id']
    end
    ContentType.where.not(id: content_type_ids).destroy_all

    join_opp_type_ids = []
    replica.get_join_opportunity_types.each do |row|
      join_opp_type = OpportunityOpportunityType.find_or_create_by!(id: row['id'])
      join_opp_type.update!(
        opportunity_id: row['opportunity_id'],
        opportunity_type_id: row['opportunity_type_id'],
        archived_at: row['archived_at']
      )
      join_opp_type_ids << row['id']
    end
    OpportunityOpportunityType.where.not(id: join_opp_type_ids).destroy_all

    join_cont_type_ids = []
    replica.get_join_content_types.each do |row|
      join_cont_type = OpportunityContentType.find_or_create_by!(id: row['id'])
      join_cont_type.update!(
        opportunity_id: row['opportunity_id'],
        content_type_id: row['content_type_id'],
        archived_at: row['archived_at']
      )
      join_cont_type_ids << row['id']
    end
    OpportunityContentType.where.not(id: join_cont_type_ids).destroy_all

    join_pubs_ids = []
    replica.get_join_publications.each do |row|
      join_pubs = OpportunityPublication.find_or_create_by!(id: row['id'])
      publication = Publication.find_by(pl_identifier: row['project_id'])
      next if publication.nil?

      join_pubs.update!(
        opportunity_id: row['opportunity_id'],
        publication_id: publication.id,
        archived_at: row['archived_at']
      )
      join_pubs_ids << row['id']
    end
    OpportunityPublication.where.not(id: join_pubs_ids).destroy_all

    replica.close

    client_oppo_ids = []
    Client.all.each do |c|
      c.publications.each do |p|
        p.opportunities.each do |o|
          client_oppo_ids << ClientOpportunity.find_or_create_by!(client: c, opportunity: o).id
        end
      end
    end
    ClientOpportunity.where.not(id: client_oppo_ids).destroy_all
  end
end
