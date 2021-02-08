class AddColumnLastExportedBatchSizeToIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :iterations,
               :last_export_batch_size,
               :integer,
               after: :export
  end
end
