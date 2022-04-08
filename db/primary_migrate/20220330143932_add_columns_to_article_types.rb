class AddColumnsToArticleTypes < ActiveRecord::Migration[6.0]
  def change
    add_reference :article_types, :topic, null: true, foreign_key: true, after: :current_iteration_id
    add_reference :article_types, :kind, null: true, foreign_key: true, after: :current_iteration_id

    add_column :article_types, :original_publish_date, :date, after: :staging_table_attached
    add_column :article_types, :source_link, :string, after: :staging_table_attached
    add_column :article_types, :source_name, :string, after: :staging_table_attached
    add_column :article_types, :source_type, :string, after: :staging_table_attached
  end
end
