# frozen_string_literal: true

class CreateStoryTypes < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :story_types do |t|
      t.belongs_to :editor
      t.belongs_to :developer
      t.belongs_to :data_set

      t.string  :name
      t.text    :body, limit: 1_572_864
      t.string  :description, limit: 1000
      t.date    :desired_launch
      t.date    :last_launch
      t.date    :last_export
      t.date    :deadline
      t.string  :dev_status, default: 'Not Started'
      t.timestamps
    end
  end
end
