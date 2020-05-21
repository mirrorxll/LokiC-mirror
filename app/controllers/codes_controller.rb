# frozen_string_literal: true

class CodesController < ApplicationController # :nodoc:
  def create
    @story_type.code.attach(params[:code]) unless @story_type.code.attached?
  end

  def destroy
    @story_type.code.purge if @story_type.code.attached?
  end
end
