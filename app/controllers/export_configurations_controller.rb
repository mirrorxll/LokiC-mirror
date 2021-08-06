# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  before_action :render_403, if: :editor?

  def check; end

  def create
    render_403 && return if @story_type.staging_table_attached.nil?

    @story_type.update!(export_configurations_created: false, current_account: current_account)
    ExportConfigurationsJob.perform_later(@story_type, current_account, true)
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
