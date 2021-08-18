# frozen_string_literal: true

class AddLevelIdToStoryTypes < ActiveRecord::Migration[6.0]
  def up
    change_table :story_types do |t|
      t.belongs_to :level, after: :data_set_id
    end
  end

  def down
    remove_column :story_types, :level_id
  end
end
