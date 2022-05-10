# frozen_string_literal: true

class PhotoBucketsTask < ApplicationTask
  def perform(*_args)
    PipelineReplica[:production].get_photo_buckets.each do |raw_bucket|
      bucket = PhotoBucket.find_or_initialize_by(pl_identifier: raw_bucket['id'])
      bucket.name = raw_bucket['name']
      bucket.minimum_height = raw_bucket['minimum_height']
      bucket.minimum_width = raw_bucket['minimum_width']
      bucket.aspect_ratio = raw_bucket['aspect_ratio']
      bucket.save!
    end
  end
end
