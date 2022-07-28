# frozen_string_literal: true

module FactoidTypes
  class SamplesController < FactoidTypesController # :nodoc:
    before_action :find_sample, only: %i[show edit update]

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
      @sample = Article.find(params[:id])
    end

    def stories_params
      params.require(:samples).permit(:row_ids, columns: {}).to_hash
    end
  end
end
