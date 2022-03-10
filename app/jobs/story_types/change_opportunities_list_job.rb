# frozen_string_literal: true

module StoryTypes
  class ChangeOpportunitiesListJob < StoryTypesJob
    def perform(story_type)
      pubs = []
      exc_pubs = story_type.excepted_publications.map(&:publication)

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

        raw_pubs.map { |p| pubs << p unless p.in?(exc_pubs) }
      end

      default_opportunities = story_type.default_opportunities
      opportunities = story_type.opportunities

      default_opportunities.update_all(exist: false)
      opportunities.update_all(exist: false)

      pubs.map(&:client).uniq.each do |c|
        next if default_opportunities.find_by(client: c)&.update(exist: true)

        story_type.default_opportunities.create(client: c)
      end

      pubs.each do |p|
        next if opportunities.find_by(publication: p)&.update(exist: true)

        story_type.opportunities.create(client: p.client, publication: p)
      end

      default_opportunities.where(exist: false).destroy_all
      opportunities.where(exist: false).destroy_all

      StoryTypeOpportunitiesChannel.broadcast_to(story_type, true)
    end
  end
end
