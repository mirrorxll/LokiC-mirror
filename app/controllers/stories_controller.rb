# frozen_string_literal: true

class StoriesController < ApplicationController # :nodoc:
  def show
    @story = Story.find(params[:id])
  end
end