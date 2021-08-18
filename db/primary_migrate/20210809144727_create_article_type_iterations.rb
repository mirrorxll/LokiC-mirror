# frozen_string_literal: true

class CreateArticleTypeIterations < ActiveRecord::Migration[6.0]
  def change
    create_table :article_type_iterations do |t|
      t.belongs_to :article_type

      t.string :name
      t.boolean :population
      t.boolean :samples
      t.boolean :creation
      t.boolean :export
    end
  end
end
