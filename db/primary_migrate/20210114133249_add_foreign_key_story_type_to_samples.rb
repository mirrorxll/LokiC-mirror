# frozen_string_literal: true

class AddForeignKeyStoryTypeToSamples < ActiveRecord::Migration[6.0]
  def change
    change_table :samples do |t|
      t.belongs_to :story_type, after: :id
    end

    Iteration.all.each do |iter|
      Sample.where(iteration: iter).update_all(story_type_id: iter.story_type.id)
    end
  end
end
