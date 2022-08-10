# frozen_string_literal: true

module FactoidTypes
  class FactoidsController < FactoidTypesController # :nodoc:
    before_action :generate_grid, only: :index

    def index
      @tab_title = "LokiC :: Factoids ##{@factoid_type.id} <#{@factoid_type.name}>"
    end

    private

    def generate_grid
      grid_params = request.parameters[:factoid_type_iteration_factoids_grid] || {}

      @grid = FactoidTypeIterationFactoidsGrid.new(grid_params) do |scope|
        scope.where(factoid_type_id: params[:factoid_type_id], factoid_type_iteration_id: params[:iteration_id])
      end
      @grid.scope { |scope| scope.page(params[:page]).per(30) }
    end
  end
end
