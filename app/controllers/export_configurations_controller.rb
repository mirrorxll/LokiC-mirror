# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  before_action :render_403, if: :editor?

  def check; end

  def create
    render_403 && return if @story_type.staging_table_attached.nil?

    @story_type.update(creating_export_configurations: false)
    ExportConfigurationsJob.perform_later(@story_type, true)
  end

  def update_tags
    ExportConfiguration.update_tags(update_tags_params)
  end

  private

  def new_clients_publications?
    @story_type.staging_table.new_clients_publications?
  end

  def update_tags_params
    params.require(:export_configurations).permit!
  end
end
