# frozen_string_literal: true

class ExportsController < ApplicationController
  def staging
    export_to('staging')
  end

  def production
    export_to('production')
  end

  private

  def export_to(environment)
    render_400 && return unless @story_type.iteration.export.nil?

    ExportJob.set(wait: 5.second).perform_later(environment, @story_type, export_params)
    @story_type.update_iteration(export: false)
  end

  def export_params
    {}
  end
end
