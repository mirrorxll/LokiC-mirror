# frozen_string_literal: true

class CreateStoryTypeIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :story_type_iterations do |t|
      t.belongs_to :story_type

      t.boolean :populate_status,       default: false
      t.boolean :create_status,         default: false
      t.timestamps
    end
  end
end