# frozen_string_literal: true

class CreateStoryTypeIterations < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :story_type_iterations do |t|
      t.boolean :populate_status,       default: false
      t.boolean :create_status,         default: false

      t.belongs_to :story_type

      t.timestamps
    end
  end
end
