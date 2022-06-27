# frozen_string_literal: true

module FactoidTypes
  class ExportsController < FactoidTypesController
    before_action :show_sample_ids, only: :articles

    def execute
      @iteration.update!(export: false, current_account: current_account)
      ExportJob.perform_async(@iteration.id, current_account.id, params[:chunk])
    end

    def remove_exported_articles
      @iteration.update!(purge_export: true, current_account: current_account)
      PurgeExportJob.perform_async(@iteration.id, current_account.id)
    end

    def articles
      @articles = @iteration.articles.published.order(exported_at: :asc).page(params[:page]).per(30)
      @tab_title = "LokiC :: FactoidType ##{@factoid_type.id} :: Factoids"
    end

    private

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.lp_article_id] = smpl.id }
    end
  end
end
