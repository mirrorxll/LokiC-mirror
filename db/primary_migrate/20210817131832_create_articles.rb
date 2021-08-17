# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.belongs_to :article_type
      t.belongs_to :article_type_iteration

      t.integer  :staging_row_id
      t.datetime :exported_at
      t.boolean  :backdated, default: false
      t.boolean  :sampled, default: false
      t.boolean  :show, default: false
    end
  end
end
