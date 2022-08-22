# frozen_string_literal: true

module StoryTypes
  class StagingTableColumnsController < StoryTypesController
    before_action :staging_table

    def edit
      staging_table_action { @staging_table.sync }
    end

    def update
      staging_table_action do
        @staging_table.update!(columns_modifying: true)
        send_to_action_cable(@story_type, 'staging_table', 'staging table modifying in progress')

        Process.spawn(
          "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
          'rake story_type:staging_table:change_columns '\
          "staging_table_id=#{@staging_table.id} columns='#{columns_front_params.to_json}' &"
        )

        nil
      end

      render 'story_types/staging_tables/show'
    end

    private

    def columns_front_params
      if params[:columns]
        params.require(:columns).permit!.to_hash
      else
        {}
      end
    end

    def staging_table
      @staging_table = @story_type.staging_table
    end
  end
end
