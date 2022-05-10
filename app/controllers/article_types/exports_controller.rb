# frozen_string_literal: true

module ArticleTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403_editor, except: :articles, if: :editor?
    before_action :render_403_developer, only: %i[articles submit_editor_report submit_manager_report], if: :developer?
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
      @articles = @iteration.articles.published.order(exported_at: :asc).page(params[:page]).per(25)
    end

    private

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.lp_article_id] = smpl.id }
    end
  end
end
