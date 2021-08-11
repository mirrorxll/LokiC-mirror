# frozen_string_literal: true

module StoryTypes
  class PopulationsController < ApplicationController # :nodoc:
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
        PopulationJob.perform_later(@iteration, current_account, population_args)

        iteration_args = population_args.merge(current_account: current_account)
        @iteration.update!(iteration_args)
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
