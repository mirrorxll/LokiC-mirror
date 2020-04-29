# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  def show
    @story = Sample.find(params[:id])
  end
end