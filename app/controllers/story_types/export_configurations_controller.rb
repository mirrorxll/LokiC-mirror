# frozen_string_literal: true

module StoryTypes
  class ExportConfigurationsController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration


    def check; end

    def create
      render_403 && return if @story_type.staging_table_attached.nil?

      @story_type.update!(export_configurations_created: false, current_account: current_account)

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        "rake story_type:export_configurations story_type_id=#{@story_type.id} "\
        "account_id=#{current_account.id} manual=true &"
      )
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
