# frozen_string_literal: true

class AddLimparFactoidIdToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :limpar_factoid_id, :string, length: 36, after: :staging_row_id
  end
end
