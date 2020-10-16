# frozen_string_literal: true

class IterationsController < ApplicationController
  skip_before_action :set_iteration

  before_action :render_400, if: :editor?
  before_action :find_iteration, only: %i[update apply_iteration]

  def create
    @iteration = @story_type.iterations.build(iteration_params)
    @story_type.update(current_iteration: @iteration) if @iteration.save

    redirect_to @story_type
  end

  def update
    @iteration.update(iteration_params)
  end

  def apply_iteration
    @story_type.update(current_iteration: @iteration)
    @story_type.staging_table&.default_iter_id

    redirect_to @story_type
  end

  private

  def find_iteration
    @iteration = Iteration.find(params[:id])
  end

  def iteration_params
    params.require(:iteration).permit(:name)
  end
end
