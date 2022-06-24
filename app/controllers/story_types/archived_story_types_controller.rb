# frozen_string_literal: true

module StoryTypes
  class ArchivedStoryTypesController < StoryTypesController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    def index
      @grid = request.parameters[:archived_story_types_grid] || {}

      @archived_story_types_grid = ArchivedStoryTypesGrid.new(@grid, &:archived)

      respond_to do |f|
        f.html do
          @archived_story_types_grid.scope { |scope| scope.page(params[:page]).per(30) }
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
