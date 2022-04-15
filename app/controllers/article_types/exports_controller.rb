# frozen_string_literal: true

module ArticleTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403_editor, except: :articles, if: :editor?
    before_action :render_403_developer, only: %i[articles submit_editor_report submit_manager_report], if: :developer?
    before_action :show_sample_ids, only: :articles
    # before_action :removal, only: :remove_exported_articles
    # before_action :validate_params, only: :execute

    def execute
      pp '++++++++++++++++++++++', params
      # @iteration.update!(export: false, current_account: current_account)
      #TODO: for what url?
      # url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
      # ExportJob.perform_later(@iteration, current_account)
    end

    def remove_exported_articles
      pp '====================', params
      @iteration.update!(purge_export: true, current_account: current_account)
      # TODO: ProductionRemoval only for story_types
      # @removal.update!(removal_params)
      PurgeExportJob.perform_later(@iteration, current_account)
    end

    def articles
      @articles = @iteration.articles.published.order(exported_at: :asc).page(params[:page]).per(25)
    end

    private

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.lp_article_id] = smpl.id }
    end

    def validate_params
      validates_presence_of :source_link, :source_type, :source_name, :original_publish_date
    end
  end
end
