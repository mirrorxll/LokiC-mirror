# frozen_string_literal: true

module StoryTypes
  class OpportunitiesController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration

    def index; end

    def create
      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        "rake story_type:change_opportunities story_type_id=#{@story_type.id} &"
      )
    end

    def update
      @st_opportunity = @story_type.opportunities.find(params[:id])
      @st_opportunity = StoryTypeOpportunityObject.update(@st_opportunity, st_opportunity_params)
    end

    private

    def st_opportunity_params
      params.require(:st_opportunity).permit(
        :action,
        :opportunity_id,
        :opportunity_type_id,
        :content_type_id
      ).to_h
    end
  end
end
