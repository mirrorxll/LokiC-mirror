class ChangeArticleToFactoid < ActiveRecord::Migration[6.0]
  def change
    rename_table :articles, :factoids
    rename_table :article_outputs, :factoid_outputs
    rename_column :factoid_outputs, :article_id, :factoid_id
  end
end
