# frozen_string_literal: trure

class UploadCodesController < ApplicationController # :nodoc:
  before_action :find_story

  def create
    @story.code.attach(params[:code]) unless @story.code.attached?
  end

  def destrroy

  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def upload_code_params
  end
end
