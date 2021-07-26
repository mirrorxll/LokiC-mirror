# frozen_string_literal: true

class IterationsController < ApplicationController
  skip_before_action :find_parent_story_type, only: :show
  skip_before_action :set_iteration

  before_action :render_403, if: :editor?
  before_action :find_iteration, only: %i[show update apply purge]
  before_action :find_staging_table, only: :purge

  def show
    @story_type = @iteration.story_type

    render 'story_types/show'
  end

  def create
    @iteration = @story_type.iterations.build(iteration_params)

    if @iteration.save
      @story_type.update(current_iteration: @iteration)
      @story_type.staging_table&.default_iter_id
    end

    redirect_to @story_type
  end

  def update
    @iteration.update(iteration_params)
  end

  def apply
    @story_type.update(current_iteration: @iteration)
    @story_type.staging_table&.default_iter_id

    redirect_to @story_type
  end

  def purge
    staging_table_action { @staging_table.purge }

    if flash.now[:error].nil?
      @story_type.update(creating_export_configurations: nil)
      @iteration.samples.destroy_all
      @iteration.auto_feedback.destroy_all

      @iteration.update(
        population: nil, story_samples: nil,
        creation: nil, schedule: nil, export: nil
      )
    end

    render 'story_types/update_sections'
  end

  private

  def find_iteration
    @iteration = Iteration.find(params[:id])
  end

  def find_staging_table
    @staging_table = @story_type.staging_table
  end

  def iteration_params
    params.require(:iteration).permit(:name)
  end
end
