# frozen_string_literal: true

class DevelopersController < ApplicationController
  before_action :find_developer, only: :include

  def include
    render_400 && return if @story_type.developer

    @story_type.update(developer: @developer)
  end

  def exclude
    render_400 && return unless @story_type.developer

    @story_type.update(developer: nil)
  end

  private

  def find_developer
    @developer = User.find(params[:id])
  end
end
