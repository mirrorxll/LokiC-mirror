# frozen_string_literal: true

module ArticleTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403_editor, except: :articles, if: :editor?
    before_action :render_403_developer, only: %i[articles submit_editor_report submit_manager_report], if: :developer?
    before_action :show_sample_ids, only: :articles
    before_action :removal, only: :remove_exported_stories

    def execute
      @iteration.update!(export: false, current_account: current_account)
      url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
      ExportJob.perform_later(@iteration, current_account, url)
    end

    def remove_exported_stories
      @iteration.update!(purge_export: true, current_account: current_account)
      @removal.update!(removal_params)
      PurgeExportJob.perform_later(@iteration, current_account)
    end

    def articles
      @articles =
        if params[:backdated]
          @iteration.articles.exported
        else
          @iteration.articles.exported_without_backdate
        end

      @articles =
        @articles.order(backdated: :asc, published_at: :asc).page(params[:page]).per(25)
                .includes(:output, :publication)
    end

    private

    def removal
      recent_removal = @iteration.production_removals.last

      @removal =
        if recent_removal&.status.eql?(false)
          recent_removal
        else
          @iteration.production_removals.create(account: current_account)
        end
    end

    def removal_params
      params.require(:remove_exported_articles).permit(:reasons)
    end

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
    end
  end
end
