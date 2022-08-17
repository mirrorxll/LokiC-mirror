# frozen_string_literal: true

module FactoidTypes
  class ExportsController < FactoidTypesController
    before_action :show_sample_ids, only: :factoids

    def execute
      @iteration.update!(export: false, current_account: current_account)
      ExportJob.perform_async(@iteration.id, current_account.id, params[:chunk])
    end

    def remove_exported_factoids
      @iteration.update!(purge_export: true, current_account: current_account)
      PurgeExportJob.perform_async(@iteration.id, current_account.id)
    end

    def factoids
      @factoids = @iteration.factoids.published.order(exported_at: :asc).page(params[:page]).per(30)
      @tab_title = "LokiC :: FactoidType ##{@factoid_type.id} :: Factoids"
    end

    private

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.lp_factoid_id] = smpl.id }
    end
  end
end
