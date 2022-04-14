# frozen_string_literal: true

module StoryTypes
  class StagingTableIndicesController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :staging_table

    def new
      staging_table_action do
        @staging_table.index.drop(:story_per_publication)
        @staging_table.sync
        @columns = @staging_table.reload.columns.names_ids
        nil
      end
    end

    def create
      staging_table_action do
        @staging_table.update!(indices_modifying: true)

        send_to_action_cable(@story_type, 'staging_table', 'staging table modifying in progress')
        StagingTableIndexAddJob.perform_async(@staging_table.id, uniq_index_column_ids)
        nil
      end

      render 'story_types/staging_tables/show'
    end

    def destroy
      staging_table_action do
        @staging_table.update!(indices_modifying: true)

        send_to_action_cable(@story_type, 'staging_table', 'staging table modifying in progress')
        StagingTableIndexDropJob.perform_async(@staging_table.id)
        nil
      end

      render 'story_types/staging_tables/show'
    end

    private

    def uniq_index_column_ids
      if params[:index]
        params.require(:index).permit(column_ids: [])[:column_ids]
      else
        []
      end
    end

    def staging_table
      @staging_table = @story_type.staging_table
    end
  end
end

