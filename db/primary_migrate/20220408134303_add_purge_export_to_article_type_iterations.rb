class AddPurgeExportToArticleTypeIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :article_type_iterations, :purge_export, :boolean, after: :export
    add_column :article_type_iterations, :last_export_batch_size, :integer, after: :purge_export
  end
end
