# frozen_string_literal: true

module FactoidTypes
  class SamplesController < FactoidTypesController # :nodoc:
    before_action :generate_grid, only: :index
    before_action :find_sample, only: %i[show edit update]

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

    def show
      @tab_title = "LokiC :: FactoidType ##{@factoid_type.id} :: Factoid ##{@sample.id}"
      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'to_tab' }
      end
    end

    def generate
      @iteration.update!(samples: false, current_account: current_account)
      SamplesJob.perform_async(@iteration.id, current_account.id, stories_params)

      render 'factoid_types/creations/execute'
    end

    def purge
      @iteration.update!(purge_samples: false, current_account: current_account)
      PurgeSamplesJob.perform_async(@iteration.id, current_account.id)

      render 'factoid_types/creations/purge'
    end

    private

    def find_sample
      @sample = Factoid.find(params[:id])
    end

    def stories_params
      params.require(:samples).permit(:row_ids, columns: {}).to_hash
    end

    def generate_grid
      grid_params = request.parameters[:factoid_type_iteration_factoids_grid] || {}

      @grid = FactoidTypeIterationFactoidsGrid.new(grid_params) do |scope|
        scope.where(factoid_type_id: params[:factoid_type_id], factoid_type_iteration_id: params[:iteration_id])
      end
    end
  end
end
