# frozen_string_literal: true

module FactoidTypes
  class ArticlesController < FactoidTypesController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    def index
      @grid = request.parameters[:article_type_iteration_articles_grid] || {}

      @iteration_articles_grid = ArticleTypeIterationArticlesGrid.new(@grid) do |scope|
        scope.where(article_type_id: params[:article_type_id], article_type_iteration_id: params[:iteration_id])
      end

      @tab_title = "LokiC :: Factoids ##{@factoid_type.id} <#{@factoid_type.name}>"
      respond_to do |f|
        f.html do
          @iteration_articles_grid.scope { |scope| scope.page(params[:page]).per(30) }
        end
        f.csv do
          send_data @iteration_articles_grid.to_csv,
                    type: 'text/csv', disposition: 'inline',
                    filename: "LokiC_##{@factoid_type.id}_#{@factoid_type.name}_#{@iteration.name}_factoid_#{Time.now}.csv"
        end
      end
    end
  end
end
