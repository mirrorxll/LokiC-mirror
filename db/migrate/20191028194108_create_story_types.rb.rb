# frozen_string_literal: true

class CreateStoryTypes < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :story_types do |t|
      t.belongs_to :editor
      t.belongs_to :developer
      t.belongs_to :data_set

      t.string  :name
      t.timestamps
    end

    add_index :story_types, :name, unique: true
  end
end
