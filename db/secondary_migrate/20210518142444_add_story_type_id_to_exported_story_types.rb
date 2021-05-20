# frozen_string_literal: true

class AddStoryTypeIdToExportedStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :exported_story_types, :story_type_id, :integer,
               limit: 8, after: :developer_id
    add_index :exported_story_types, :story_type_id
  end
end
