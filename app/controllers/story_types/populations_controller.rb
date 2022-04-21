# frozen_string_literal: true

module StoryTypes
  class PopulationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :staging_table

    def execute
      render_403 && return if [true, false].include?(@iteration.population)

      flash.now[:error] =
        if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
          staging_table_deleted
        elsif @staging_table.index.list.empty?
          'first...create unique index'
        end

      if flash.now[:error].nil?
        population_args = population_params
        iteration_args = population_args.merge(current_account: current_account)
        @iteration.update!(iteration_args)

        send_to_action_cable(@story_type, 'staging_table', 'population in progress')
        PopulationJob.perform_async(@iteration.id, current_account.id, population_args)
      end

      render 'story_types/staging_tables/show'
    end

    private

    def population_params
      {
        population: false,
        population_args: params.require(:population).permit(:args)[:args]
      }
    end

    def staging_table
      @staging_table = @story_type.staging_table
    end
  end
end
