# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :exported_stories, if: :editor?

  def export
    ExportJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(export: false)

    render 'export'
  end

  def exported_stories
    @exported = @iteration.samples.where.not("pl_#{PL_TARGET}_story_id".to_sym => nil)
    @to_report = @exported.includes(:output, :publication).limit(2_000)
  end

  def section; end
end
