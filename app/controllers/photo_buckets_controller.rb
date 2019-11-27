# frozen_string_literal: true

class PhotoBucketsController < ApplicationController # :nodoc:
  before_action :find_photo_bucket

  def include
    render_400 && return if @story.photo_buckets.count.positive?

    @story.photo_buckets << @photo_bucket
  end

  def exclude
    render_400 && return unless @story.photo_buckets.exists?(@photo_bucket.id)

    @story.photo_buckets.clear
  end

  private

  def find_photo_bucket
    @photo_bucket = PhotoBucket.find(params[:id])
  end
end
