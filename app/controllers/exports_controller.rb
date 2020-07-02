# frozen_string_literal: true

class ExportsController < ApplicationController
  def production
    ExportJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(export: false)

    render 'export'
  end

  def section; end
end
