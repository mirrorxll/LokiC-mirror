# frozen_string_literal: true

module FactoidTypes
  class ArticlesController < FactoidTypesController # :nodoc:
    def index
      @grid = request.parameters[:article_type_iteration_articles_grid] || {}

      @iteration_articles_grid = FactoidTypeIterationArticlesGrid.new(@grid) do |scope|
        scope.where(factoid_type_id: params[:factoid_type_id], factoid_type_iteration_id: params[:iteration_id])
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
