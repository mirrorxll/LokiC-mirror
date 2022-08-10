# frozen_string_literal: true

module FactoidTypes
  class FactoidsController < FactoidTypesController # :nodoc:
    before_action :generate_grid, only: :index

    def index
      @tab_title = "LokiC :: Factoids ##{@factoid_type.id} <#{@factoid_type.name}>"

      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]) }
        end
        f.csv do
          send_data @grid.to_csv, type: 'text/csv', disposition: 'inline',
                    filename: "LokiC_##{@factoid_type.id}_#{@factoid_type.name}_#{@iteration.name}_factoids_#{Time.now}.csv"
        end
      end
    end

    private

    def generate_grid
      grid_params = request.parameters[:factoid_type_iteration_factoids_grid] || {}

      @grid = FactoidTypeIterationFactoidsGrid.new(grid_params) do |scope|
        scope.where(factoid_type_id: params[:factoid_type_id], factoid_type_iteration_id: params[:iteration_id])
      end
    end
  end
end
