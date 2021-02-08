# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  before_action :render_400, if: :editor?

  def check; end

  def create
    ExportConfigurationsJob.perform_later(@iteration)

    @iteration.update(export_configurations: false)
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
