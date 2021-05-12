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

  def submit_editor_report
    @report.update(editor_report_params)
  end

  def submit_manager_report
    @report.update(manager_report_params)
  end

  private

  def show_sample_ids
    @show_sample_ids = {}
    @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
  end

  def editor_report
    @report =
      @iteration.editor_post_export_report ||
      @iteration.create_editor_post_export_report(submitter: current_account, report_type: 'editor')
  end

  def manager_report
    @report =
      @iteration.manager_post_export_report ||
      @iteration.create_manager_post_export_report(submitter: current_account, report_type: 'manager')
  end

  def editor_report_params
    answers = params.require(:answers).permit!
    answers.each_key { |k| answers[k] = (answers[k].eql?('true') ? true : false) if k.start_with?('q') }

    { answers: answers }
  end

  def manager_report_params
    answers = params.require(:answers).permit!

    { answers: answers }
  end
end
