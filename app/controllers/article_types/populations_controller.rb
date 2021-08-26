# frozen_string_literal: true

module ArticleTypes
  class PopulationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?
    before_action :staging_table

    def execute
      render_403 && return if [true, false].include?(@iteration.population)

      flash.now[:error] =
        if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
          detached_or_delete
        elsif @staging_table.index.list.empty?
          'first...create unique index'
        end

      if flash.now[:error].nil?
        population_args = population_params
        iteration_args = population_args.merge(current_account: current_account)
        @iteration.update!(iteration_args)

        PopulationJob.perform_later(@iteration, current_account, population_args)
      end

      render 'article_types/staging_tables/show'
    end

    def purge
      @iteration.update!(purge_population: false, current_account: current_account)
      PurgePopulationJob.perform_later(@staging_table, @iteration, current_account)
    end

    private

    def population_params
      {
        population: false,
        population_args: params.require(:population).permit(:args)[:args]
      }
    end

    def staging_table
      @staging_table = @article_type.staging_table
    end
  end
end
