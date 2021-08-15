# frozen_string_literal: true

class ChangeStagingTablesToPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :staging_tables, :story_type_id
    rename_column :staging_tables, :story_type_id, :staging_table_id
    add_column :staging_tables, :staging_table_type, :string, after: :id
    add_index :staging_tables, %i[staging_table_type staging_table_id]

    FactCheckingDoc.reset_column_information
    FactCheckingDoc.update_all(fcd_type: 'StoryType')
  end
end
