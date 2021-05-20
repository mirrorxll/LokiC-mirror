# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :stories, if: :editor?
  before_action :render_400, only: :stories, if: :developer?
  before_action :render_400, only: %i[submit_editor_report submit_manager_report], if: :developer?
  before_action :show_sample_ids, only: :stories
  before_action :editor_report,   only: :submit_editor_report
  before_action :manager_report,  only: :submit_manager_report

  def create
    @iteration.update(export: false)
    url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])
    ExportJob.perform_later(@iteration, url)
  end

  def remove_from_pl
    @iteration.update(removing_from_pl: true)
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

  def show_sample_ids
    @show_sample_ids = {}
    @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
  end
end
