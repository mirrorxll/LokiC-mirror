# frozen_string_literal: true

module StoryTypes
  class OpportunitiesJob < ApplicationJob
    sidekiq_options queue: :cron_tab

    def perform(*_args)
      replica = PipelineReplica[:production]

      replica.get_agencies.each do |row|
        agency = Agency.find_or_create_by!(id: row['id'])
        agency.update!(name: row['name'], partner: row['partner'])
        agency.touch
      end
      Agency.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_opportunities.each do |row|
        opportunity = Opportunity.find_or_create_by!(id: row['id'])
        opportunity.update!(
          name: row['name'],
          archived_at: row['archived_at'],
          agency_id: row['agency_id']
        )
        opportunity.touch
      end
      Opportunity.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_opportunity_types.each do |row|
        opportunity_type = OpportunityType.find_or_create_by!(id: row['id'])
        opportunity_type.update!(name: row['name'])
        opportunity_type.touch
      end
      OpportunityType.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_content_types.each do |row|
        content_type = ContentType.find_or_create_by!(id: row['id'])
        content_type.update!(
          name: row['name'],
          archived_at: row['archived_at'],
          content_group_id: row['content_group_id']
        )
        content_type.touch
      end
      ContentType.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_join_opportunity_types.each do |row|
        join_opp_type = OpportunityOpportunityType.find_or_create_by!(id: row['id'])
        join_opp_type.update!(
          opportunity_id: row['opportunity_id'],
          opportunity_type_id: row['opportunity_type_id'],
          archived_at: row['archived_at']
        )
        join_opp_type.touch
      end
      OpportunityOpportunityType.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_join_content_types.each do |row|
        join_cont_type = OpportunityContentType.find_or_create_by!(id: row['id'])
        join_cont_type.update!(
          opportunity_id: row['opportunity_id'],
          content_type_id: row['content_type_id'],
          archived_at: row['archived_at']
        )
        join_cont_type.touch
      end
      OpportunityContentType.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.get_join_publications.each do |row|
        join_pubs = OpportunityPublication.find_or_create_by!(id: row['id'])
        publication = Publication.find_by(pl_identifier: row['project_id'])
        next if publication.nil?

        join_pubs.update!(
          opportunity_id: row['opportunity_id'],
          publication_id: publication.id,
          archived_at: row['archived_at']
        )
        join_pubs.touch
      end
      OpportunityPublication.where('DATE(updated_at) < CURRENT_DATE()').destroy_all

      replica.close

      Client.all.each do |c|
        c.publications.each do |p|
          p.opportunities.each do |o|
            ClientOpportunity.find_or_create_by!(client: c, opportunity: o).touch
          end
        end
      end

      ClientOpportunity.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
    end
  end
end
