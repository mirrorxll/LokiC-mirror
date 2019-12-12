# frozen_string_literal: true

class CreateStoryIterations < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :story_iterations do |t|
      t.string  :iteration
      t.boolean :populate_status,       default: false
      t.boolean :stories_create_status, default: false

      t.belongs_to :story

      t.timestamps
    end
  end
end
