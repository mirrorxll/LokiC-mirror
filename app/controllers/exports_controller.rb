# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :render_400, except: :exported_stories, if: :editor?

  def export
    ExportJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(export: false)
  end

  def section; end
end
