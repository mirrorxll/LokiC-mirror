# frozen_string_literal: true

module ArticleTypes
  class StagingTableIndicesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?
    before_action :staging_table

    def new
      staging_table_action do
        @staging_table.index.drop(:staging_table_uniq_row)
        @staging_table.sync
        @columns = @staging_table.reload.columns.names_ids
        nil
      end
    end

    def create
      staging_table_action do
        @staging_table.update!(indices_modifying: true)
        StagingTableIndexAddJob.perform_later(@staging_table, uniq_index_column_ids)
        nil
      end

      render 'article_types/staging_tables/show'
    end

    def destroy
      staging_table_action do
        @staging_table.update!(indices_modifying: true)
        StagingTableIndexDropJob.perform_later(@staging_table)
        nil
      end

      render 'article_types/staging_tables/show'
    end

    private

    def uniq_index_column_ids
      if params[:index]
        params.require(:index).permit(column_ids: [])[:column_ids].map!(&:to_sym)
      else
        []
      end
    end

    def staging_table
      @staging_table = @article_type.staging_table
    end
  end
end
