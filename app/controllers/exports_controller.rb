# frozen_string_literal: true

class ExportsController < ApplicationController
  def staging
    export_to('staging')
  end

  def production
    export_to('production')
    render 'export'
  end

  private

  def export_to(environment)
    ExportJob.set(wait: 2.second).perform_later(environment, @story_type)
    @story_type.update_iteration(export: false)
  end
end
