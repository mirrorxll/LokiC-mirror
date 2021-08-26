# frozen_string_literal: true

class AddArticleTypesCountToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sets, :article_types_count, :integer
  end
end
