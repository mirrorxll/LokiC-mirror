# frozen_string_literal: true

class CreatePhotoBuckets < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :photo_buckets do |t|
      t.integer :pl_identifier
      t.string  :name
      t.integer :minimum_height
      t.integer :minimum_width
      t.string  :aspect_ratio
      t.timestamps
    end
  end
end
