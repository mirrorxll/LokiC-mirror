class ChangeArticleTypesToFactoidTypes < ActiveRecord::Migration[6.0]
  def change
    rename_table :article_types, :factoid_types
    rename_table :article_type_iterations, :factoid_type_iterations
    rename_column :factoid_type_iterations, :article_type_id, :factoid_type_id
    rename_column :articles, :article_type_id, :factoid_type_id
    rename_column :articles, :article_type_iteration_id, :factoid_type_iteration_id
    rename_column :data_sets, :article_types_count, :factoid_types_count
    rename_column :published_factoids, :article_type_id, :factoid_type_id
  end
end
