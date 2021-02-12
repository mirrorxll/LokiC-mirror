# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :exported_stories, if: :editor?

  def export
    @iteration.update(export: false)
    ExportJob.perform_later(@iteration)
  end

  def remove_from_pl
    @iteration.update(removing_from_pl: true)
    RemoveFromPlJob.perform_later(@iteration)
  end

  def section; end

  def exported_stories
    redirect_to story_type_iteration_samples_path(params[:story_type_id], params[:iteration_id])
  end
end
