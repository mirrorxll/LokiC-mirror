# frozen_string_literal: true

module Api
  module StoryTypes
    class OpportunitiesController < Api::StoryTypesController
      before_action :find_opportunity
      before_action :find_st_opportunity

      def update
        # @st_opportunity.update(opportunity: @opportunity)
        opportunity_types = @opportunity.opportunity_types.map { |ot| { id: ot.id, name: ot.name } }
        content_types = @opportunity.content_types.map { |ct| { id: ct.id, name: ct.name } }

        render json: { opportunity_types: opportunity_types, content_types: content_types }
      end

      def destroy

      end

      private

      def find_st_opportunity
        @st_opportunity = @story_type.opportunities.find(params[:id])
      end

      def find_opportunity
        opp = params.require(:opportunity).permit(:id)
        @opportunity = Opportunity.find_by(id: '184b2bd5-6254-11ec-a59a-0aa8e3df48ce', archived_at: nil)
      end
    end
  end
end
