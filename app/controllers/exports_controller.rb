# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :exported_stories, if: :editor?
  before_action :exported_stories, :show_sample_ids

  def export
    @iteration.update(export: false)
    url = exported_stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
    ExportJob.perform_later(@iteration, url)
  end

  def remove_from_pl
    @iteration.update(removing_from_pl: true)
    RemoveFromPlJob.perform_later(@iteration)
  end

  def exported_stories
    @samples =
      if params[:backdated]
        @iteration.samples.exported
      else
        @iteration.samples.exported_without_backdate
      end

    @samples =
      @samples.order(backdated: :asc, published_at: :asc).page(params[:page]).per(4)
              .includes(:output, :publication)
  end

  private

  def show_sample_ids
    @show_sample_ids = {}
    @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
  end
end
