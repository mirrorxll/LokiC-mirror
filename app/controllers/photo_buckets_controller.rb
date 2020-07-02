# frozen_string_literal: true

class PhotoBucketsController < ApplicationController # :nodoc:
  before_action :find_photo_bucket, only: :include

  def include
    render_400 && return if @story_type.photo_bucket

    @story_type.update(photo_bucket: @photo_bucket)
  end

  def exclude
    render_400 && return unless @story_type.photo_bucket

    @story_type.update(photo_bucket: nil)
  end

  private

  def find_photo_bucket
    @photo_bucket = PhotoBucket.find(params[:id])
  end
end
