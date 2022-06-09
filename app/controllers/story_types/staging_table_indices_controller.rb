# frozen_string_literal: true

module StoryTypes
  class StagingTableIndicesController < StoryTypesController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

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

        Process.spawn(
          "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
          'rake story_type:staging_table:add_index '\
          "staging_table_id=#{@staging_table.id} columns='#{uniq_index_column_params.to_json}' &"
        )

        nil
      end

      render 'story_types/staging_tables/show'
    end

    def destroy
      staging_table_action do
        @staging_table.update!(indices_modifying: true)
        send_to_action_cable(@story_type, 'staging_table', 'staging table modifying in progress')

        Process.spawn(
          "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
          "rake story_type:staging_table:drop_index staging_table_id=#{@staging_table.id} &"
        )

        nil
      end

      render 'story_types/staging_tables/show'
    end

    private

    def uniq_index_column_params
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
