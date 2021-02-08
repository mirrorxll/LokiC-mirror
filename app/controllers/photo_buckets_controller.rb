# frozen_string_literal: true

class PhotoBucketsController < ApplicationController # :nodoc:
  before_action :render_400, if: :developer?
  before_action :find_photo_bucket, only: :include

  def include
    render_400 && return if @story_type.photo_bucket

    @story_type.update(photo_bucket: @photo_bucket)
    @story_type.export_configurations.update_all(photo_bucket_id: @photo_bucket.id)
  end

  def exclude
    render_400 && return unless @story_type.photo_bucket

    @story_type.update(photo_bucket: nil)
    @story_type.export_configurations.update_all(photo_bucket_id: nil)
  end

  private

  def find_photo_bucket
    @photo_bucket = PhotoBucket.find(params[:id])
  end
end
