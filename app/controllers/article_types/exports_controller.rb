# frozen_string_literal: true

module ArticleTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403_editor, except: :articles, if: :editor?
    before_action :render_403_developer, only: %i[articles submit_editor_report submit_manager_report], if: :developer?
    before_action :get_factoid_ids, only: :remove_selected_factoids
    before_action :get_factoids, only: [:articles, :update_section]

    def execute
      @iteration.update!(export: false, current_account: current_account)
      ExportJob.perform_async(@iteration.id, current_account.id, params[:chunk])
    end

    def remove_exported_articles
      @iteration.update!(purge_export: true, current_account: current_account)
      PurgeExportJob.perform_async(@iteration.id, current_account.id)
    end

    def articles
      @tab_title = "LokiC :: FactoidType ##{@article_type.id} :: Factoids"
    end

    def remove_selected_factoids
      @iteration.update!(purge_export: true, current_account: current_account)
      send_to_factoids_action_cable(@article_type, @iteration, 'export', 'exported_factoids', 'removing factoids')
      PurgeFactoidsJob.new.perform(@iteration.id, current_account.id, @factoid_ids)
    end

    def update_section; end

    private

    def get_factoids
      @articles  = @iteration.articles.published.order(exported_at: :asc, id: :asc).page(params[:page]).per(25)
    end

    def get_factoid_ids
      @factoid_ids = params[:factoids_ids].split(',')
    end
  end
end
