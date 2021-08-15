# frozen_string_literal: true

module StoryTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403_editor, except: :stories, if: :editor?
    before_action :render_403_developer, only: %i[stories submit_editor_report submit_manager_report], if: :developer?
    before_action :show_sample_ids, only: :stories
    before_action :removal, only: :remove_exported_stories

    def execute
      @iteration.update!(export: false, current_account: current_account)
      url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
      ExportJob.perform_later(@iteration, current_account, url)
    end

    def remove_exported_stories
      @iteration.update!(removing_from_pl: true, current_account: current_account)
      @removal.update!(removal_params)
      RemoveFromPlJob.perform_later(@iteration, current_account)
    end

    def stories
      @stories =
        if params[:backdated]
          @iteration.stories.exported
        else
          @iteration.stories.exported_without_backdate
        end

      @stories =
        @stories.order(backdated: :asc, published_at: :asc).page(params[:page]).per(25)
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
      params.require(:remove_exported_stories).permit(:reasons)
    end

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
    end
  end
end
