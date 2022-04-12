# frozen_string_literal: true

module StoryTypes
  class ExportConfigurationsController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?

    def check; end

    def create
      render_403 && return if @story_type.staging_table_attached.nil?

      @story_type.update!(export_configurations_created: false, current_account: current_account)
      ExportConfigurationsJob.perform_async(@story_type.id, current_account.id, true)
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
end
