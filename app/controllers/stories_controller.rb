# frozen_string_literal: true

class StoriesController < ApplicationController # :nodoc:
  before_action :find_book, except: %i[index]

  def index
    @stories = Story.all
  end

  def show
  end

  private

  def find_book
    @story = Story.find(params[:id])
  end
end
