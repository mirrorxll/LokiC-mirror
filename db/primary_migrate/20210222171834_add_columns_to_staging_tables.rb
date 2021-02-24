class AddColumnsToStagingTables < ActiveRecord::Migration[6.0]
  def change
    add_column :staging_tables,
               :columns_modifying,
               :boolean,
               default: false, after: :name

    add_column :staging_tables,
               :indices_modifying,
               :boolean,
               default: false, after: :columns_modifying

  end
end
