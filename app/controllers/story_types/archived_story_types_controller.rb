# frozen_string_literal: true

module StoryTypes
  class ArchivedStoryTypesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    def index
      @grid_params = if request.parameters[:archived_story_types_grid]
                       request.parameters[:archived_story_types_grid]
                     else
                       developer? ? { developer: current_account.id } : {}
                     end

      @archived_story_types_grid = ArchivedStoryTypesGrid.new(@grid_params, &:archived)

      respond_to do |f|
        f.html do
          @archived_story_types_grid.scope { |scope| scope.page(params[:page]).per(50) }
        end

        f.csv do
          send_data(
            @archived_story_types_grid.to_csv,
            type: 'text/csv',
            disposition: 'inline',
            filename: "lokic_archived_story_types_#{Time.now}.csv"
          )
        end
      end
    end
  end
end
