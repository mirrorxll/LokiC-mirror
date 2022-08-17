# frozen_string_literal: true

module FactoidTypes
  class ExportsController < FactoidTypesController
    before_action :get_factoid_ids, only: :remove_selected_factoids
    before_action :get_factoids, only: [:factoids, :update_section]

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

    # remove factoids from Limpar, 'articles' table and staging table
    def remove_selected_factoids
      @iteration.update!(purge_export: true, current_account: current_account)
      send_to_action_cable(@factoid_type, @iteration, 'export', 'exported_factoids', 'removing factoids')

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        "rake factoid_type:iteration:purge_exported_factoids iteration_id=#{@iteration.id} "\
        "account_id=#{current_account.id} factoid_ids=#{@factoid_ids} &"
      )
    end

    def update_section; end

    private

    def get_factoids
      @articles  = @iteration.factoids.published.order(exported_at: :asc, id: :asc).page(params[:page]).per(25)
    end

    def get_factoid_ids
      @factoid_ids = params[:factoids_ids]
    end
  end
end
