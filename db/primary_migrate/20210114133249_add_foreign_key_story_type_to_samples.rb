# frozen_string_literal: true

class AddForeignKeyStoryTypeToSamples < ActiveRecord::Migration[6.0]
  def change
    change_table :samples do |t|
      t.belongs_to :story_type, after: :id
    end
  end
end
