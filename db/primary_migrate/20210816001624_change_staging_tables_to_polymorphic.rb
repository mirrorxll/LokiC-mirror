# frozen_string_literal: true

class ChangeStagingTablesToPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :staging_tables, :story_type_id
    rename_column :staging_tables, :story_type_id, :staging_tableable_id
    add_column :staging_tables, :staging_tableable_type, :string, after: :id
    add_index :staging_tables, %i[staging_tableable_type staging_tableable_id], name: :polymorphic_index

    StagingTable.reset_column_information
    StagingTable.update_all(staging_tableable_type: 'StoryType')
  end
end
