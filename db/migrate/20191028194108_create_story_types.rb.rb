# frozen_string_literal: true

class CreateStoryTypes < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :story_types do |t|
      t.belongs_to :editor
      t.belongs_to :developer
      t.belongs_to :data_set
      t.belongs_to :frequency
      t.belongs_to :photo_bucket
      t.belongs_to :tag

      t.string :name
      t.datetime :last_export, default: nil
      t.timestamps
    end

    add_index :story_types, :name, unique: true
  end
end
