# frozen_string_literal: true

module StoryTypes
  class SetDefaultOpportunitiesJob < StoryTypesJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      opportunities = story_type.opportunities

      story_type.default_opportunities.each do |def_opp|
        cl_opportunities = opportunities.where(client: def_opp.client)

        if def_opp.opportunity.nil?
          cl_opportunities.update_all(
            opportunity_id: nil,
            opportunity_type_id: nil,
            content_type_id: nil
          )
          next
        end

        cl_opportunities.each do |opp|
          if opp.publication.opportunities.exists?(def_opp.opportunity.id)
            opp.update!(
              opportunity: def_opp.opportunity,
              opportunity_type: def_opp.opportunity_type,
              content_type: def_opp.content_type
            )
          else
            opp.update!(
              opportunity_id: nil,
              opportunity_type_id: nil,
              content_type_id: nil
            )
          end
        end
      end

      StoryTypeOpportunitiesChannel.broadcast_to(story_type, true)
    end
  end
end
