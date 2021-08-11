# frozen_string_literal: true

module StoryTypes
  class PhotoBucketsController < ApplicationController # :nodoc:
    before_action :render_403, if: :developer?
    before_action :find_photo_bucket, only: :include

    def include
      render_403 && return if @story_type.photo_bucket

      @story_type.update!(photo_bucket: @photo_bucket, current_account: current_account)
      @story_type.export_configurations.update_all(photo_bucket_id: @photo_bucket.id)
    end

    def exclude
      render_403 && return unless @story_type.photo_bucket

      @story_type.update!(photo_bucket: nil, current_account: current_account)
      @story_type.export_configurations.update_all(photo_bucket_id: nil)
    end

    private

    def find_photo_bucket
      @photo_bucket = PhotoBucket.find(params[:id])
    end
  end
end
