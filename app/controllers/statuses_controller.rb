# frozen_string_literal: true

class StatusesController < ApplicationController
  before_action :render_400, if: :editor?
  before_action :find_iteration,  only: :change
  before_action :find_status,     only: :change

  def form; end

  def change
    @iteration.statuses.destroy_all
    @iteration.statuses << @status
  end

  private

  def find_iteration
    @iteration = @story_type.iteration
  end

  def find_status
    @status = Status.find(params[:id])
  end
end
