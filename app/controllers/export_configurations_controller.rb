# frozen_string_literal: true

class ExportConfigurationsController < ApplicationController
  def check; end

  def create
    ExportConfigurationsJob.perform_later(@story_type)
  end

  private

  def new_clients_publications?
    @story_type.staging_table.new_clients_publications?
  end
end
