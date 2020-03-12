# frozen_string_literal: true

class CreateJoinTableStoryTypePhotoBucket < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :story_types, :photo_buckets, table_name: 'story_types__photo_buckets' do |t|
      t.index %i[story_type_id photo_bucket_id], unique: true, name: 'index_story_types__photo_buckets_story_type_id_photo_bucket_id'
    end
  end
end
