# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?
  before_action :staging_table

  def create
    render_400 && return unless @iteration.population.nil?

    flash.now[:error] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        detached_or_delete
      elsif @staging_table.index.list.empty?
        'First...create unique index'
      end

    if flash.now[:error].nil?
      args = population_params[:args]
      PopulationJob.perform_later(@iteration, args)
      @iteration.update(population: false, population_args: args)
    end

    render 'staging_tables/show'
  end

  def destroy
    staging_table_action { @staging_table.purge }

    if flash.now[:error].nil?
      @iteration.samples.destroy_all
      @iteration.auto_feedback.destroy_all
      @iteration.update(
        population: nil, export_configurations: nil,
        story_samples: nil, creation: nil, schedule: nil, export: nil
      )
    end
    render 'staging_tables/show'
  end

  private

  def population_params
    params.require(:population).permit(:args)
  end

  def staging_table
    @staging_table = @story_type.staging_table
  end
end
