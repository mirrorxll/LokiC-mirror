# frozen_string_literal: true

class CreateArticleOutputs < ActiveRecord::Migration[6.0]
  def change
    create_table :article_outputs do |t|
      t.belongs_to :article

      t.text :body, limit: 2.megabytes - 1
      t.timestamps
    end
  end
end
