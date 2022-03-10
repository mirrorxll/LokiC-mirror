# frozen_string_literal: true

module StoryTypes
  class ChangeOpportunitiesListJob < StoryTypesJob
    def perform(story_type)
      pubs = []

      story_type.clients_publications_tags.each do |row|
        pub = row.publication

        raw_pubs =
          if pub.nil? || pub.name.eql?('all publication')
            row.client.publications
          elsif pub.name.eql?('all local publications')
            row.client.local_publications
          elsif pub.name.eql?('all statewide publications')
            row.client.statewide_publications
          else
            [row.publication]
          end

        raw_pubs.map { |p| pubs << p }
      end

      story_type.excepted_publications.each do |ex_pub|
        pubs.delete(ex_pub.publication)
      end

      opportunities = story_type.opportunities
      opportunities.update_all(exist: false)

      pubs.each do |pub|
        opportunity = opportunities.find_by(publication: pub)

        if opportunity
          opportunity.update(exist: true)
        else
          story_type.opportunities.create(publication: pub)
        end
      end

      opportunities.where(exist: false).destroy_all

      StoryTypePublicationsChannel.broadcast_to(story_type, { success: true })
    end
  end
end
