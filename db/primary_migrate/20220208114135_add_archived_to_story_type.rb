class AddArchivedToStoryType < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :archived, :boolean, after: :migrated, default: false
  end
end
