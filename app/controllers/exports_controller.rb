# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400_editor, except: :stories, if: :editor?
  before_action :render_400_developer, only: %i[stories submit_editor_report submit_manager_report], if: :developer?
  before_action :show_sample_ids, only: :stories
  before_action :removal, only: :remove_exported_stories

  def execute
    @iteration.update(export: false)
    url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
    ExportJob.perform_later(@iteration, url)
  end

  def remove_exported_stories
    @iteration.update(removing_from_pl: true)
    @removal.update(removal_params)
    RemoveFromPlJob.perform_later(@iteration)
  end

  def stories
    @samples =
      if params[:backdated]
        @iteration.samples.exported
      else
        @iteration.samples.exported_without_backdate
      end

    @samples =
      @samples.order(backdated: :asc, published_at: :asc).page(params[:page]).per(25)
              .includes(:output, :publication)
  end

  private

  def removal
    recent_removal = @iteration.production_removals.last
    @removal = recent_removal&.status ? recent_removal : @iteration.production_removals.create(account: current_account)
  end

  def removal_params
    params.require(:remove_exported_stories).permit(:reasons)
  end

  def show_sample_ids
    @show_sample_ids = {}
    @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
  end
end
