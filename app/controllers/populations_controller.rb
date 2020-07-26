# frozen_string_literal: true

class PopulationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?
  before_action :staging_table

  def create
    render_400 && return unless @story_type.iteration.population.nil?

    flash.now[:error] =
      if @staging_table.nil?
        detached_or_delete
      elsif @staging_table.index.list.empty?
        'First...create unique index'
      end

    if flash.now[:error].nil?
      args = population_params[:args]
      PopulationJob.set(wait: 2.second).perform_later(@story_type, args)
      @story_type.update_iteration(population: false, population_args: args)
    end
    render 'staging_tables/show'
  end

  def destroy
    if @staging_table.nil?
      flash.now[:error] = detached_or_delete
    else
      @staging_table.purge
      @story_type.iteration.samples.destroy_all
      @story_type.iteration.feedback.destroy_all
      @story_type.update_iteration(
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
