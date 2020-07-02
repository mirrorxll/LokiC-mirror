# frozen_string_literal: true

class IterationsController < ApplicationController
  before_action :find_iteration, only: %i[show edit update destroy]

  def create
    @iteration = @story_type.iterations.build(iteration_params)
    @story_type.update(current_iteration: @iteration) if @iteration.save

    redirect_to @story_type
  end

  def edit; end

  def update
    @iteration.update(iteration_params)
  end

  def destroy
    @iteration.destroy
  end

  private

  def find_iteration
    @iteration = Iteration.find(params[:id])
  end

  def iteration_params
    params.require(:iteration).permit(:name)
  end
end
