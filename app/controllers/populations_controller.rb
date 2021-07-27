# frozen_string_literal: true

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
      args = population_params
      @iteration.update!(args)
      PopulationJob.perform_later(@iteration, args)
    end

    render 'staging_tables/show'
  end

  private

  def population_params
    {
      population: false,
      population_args: params.require(:population).permit(:args)[:args],
      account: current_account
    }
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end
