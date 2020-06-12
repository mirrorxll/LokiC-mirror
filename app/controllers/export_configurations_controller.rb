# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  def check; end

  def create
    # render_400 && return unless @story_type.iteration.export_configurations.nil?

    ExportConfigurationsJob.set(wait: 2.seconds).perform_later(@story_type)
    @story_type.update_iteration(export_configurations: false)
  end

  def update_tags

  end

  private

  def new_clients_publications?
    @story_type.staging_table.new_clients_publications?
  end
end
