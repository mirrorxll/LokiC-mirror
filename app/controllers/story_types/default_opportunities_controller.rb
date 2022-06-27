# frozen_string_literal: true

module StoryTypes
  class DefaultOpportunitiesController < StoryTypesController
    skip_before_action :set_story_type_iteration

    def update
      @st_def_opportunity = @story_type.default_opportunities.find(params[:id])
      @st_def_opportunity = StoryTypeDefaultOpportunityObject.update(@st_def_opportunity, st_def_opportunity_params)
    end

    def set
      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        "rake story_type:default_opportunities story_type_id=#{@story_type.id} &"
      )
    end

    private

    def st_def_opportunity_params
      params.require(:st_default_opportunity).permit(
        :action,
        :opportunity_id,
        :opportunity_type_id,
        :content_type_id
      ).to_h
    end
  end
end
