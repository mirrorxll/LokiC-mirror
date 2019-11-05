# frozen_string_literal: true

class CreateJoinTableStoryPhotoBucket < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :photo_buckets, table_name: 'stories__photo_buckets' do |t|
      t.index %i[story_id photo_bucket_id], unique: true
      t.index %i[photo_bucket_id story_id], unique: true
    end
  end
end
