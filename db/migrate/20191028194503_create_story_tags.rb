# frozen_string_literal: true

class CreateStoryTags < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :story_tags do |t|
      t.integer :pipeline_index
      t.string  :name

      t.timestamps
    end
  end
end
