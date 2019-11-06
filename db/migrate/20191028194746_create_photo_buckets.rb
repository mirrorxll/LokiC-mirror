# frozen_string_literal: true

class CreatePhotoBuckets < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :photo_buckets do |t|
      t.integer :pipeline_index
      t.string  :name
      t.integer :minimum_height
      t.integer :minimum_width
      t.string  :aspect_ratio

      t.timestamps
    end
  end
end
