# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :exported_stories, if: :editor?

  def export
    ExportJob.set(wait: 2.seconds).perform_later(@story_type)
    @story_type.iteration.update(export: false)
  end

  def remove_from_pl
    @story_type.iteration.update(removing_from_pl: true)
    RemoveFromPlJob.set(wait: 2.seconds).perform_later(@story_type.iteration)
  end

  def section; end

  def exported_stories
    redirect_to story_type_iteration_samples_path(params[:story_type_id], params[:iteration_id])
  end
end
