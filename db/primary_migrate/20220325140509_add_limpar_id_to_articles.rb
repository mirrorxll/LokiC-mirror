class AddLimparIdToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :limpar_id, :string, length: 36
  end
end
