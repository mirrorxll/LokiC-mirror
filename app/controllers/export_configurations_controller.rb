# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  def check; end

  def create
    ExportConfigurationsJob.set(wait: 2.seconds).perform_later(@story_type)
    @story_type.update_iteration(export_configurations: false)
  end

  def section; end

  def update_tags
    ExportConfiguration.update_tags(update_tags_params)

    render 'section'
  end

  private

  def new_clients_publications?
    @story_type.staging_table.new_clients_publications?
  end

  def update_tags_params
    params.require(:export_configurations).permit!
  end
end
