class AddColumnsToArticleTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :article_types, :source_type, :string, after: :staging_table_attached
    add_column :article_types, :source_name, :string, after: :staging_table_attached
    add_column :article_types, :source_link, :string, after: :staging_table_attached
  end
end
