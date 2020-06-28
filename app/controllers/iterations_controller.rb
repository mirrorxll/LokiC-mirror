# frozen_string_literal: true

class IterationsController < ApplicationController
  before_action :find_iteration, only: %i[edit update destroy]

  def show; end

  def new
    @iteration = @story_type.iterations.build_iteration
  end

  def create
    @iteration =
      @story_type.iterations.build_iteration(iteration_params)

    if @iteration.save
      redirect_to @story_type
    else
      render :new
    end
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

  end
end
