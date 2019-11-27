# frozen_string_literal: true

class CodesController < ApplicationController # :nodoc:
  def create
    @story.code.attach(params[:code]) unless @story.code.attached?
  end

  def destroy
    @story.code.purge if @story.code.attached?
  end
end
