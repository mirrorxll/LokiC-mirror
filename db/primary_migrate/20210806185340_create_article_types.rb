# frozen_string_literal: true

class CreateArticleTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :article_types do |t|
      t.belongs_to :editor
      t.belongs_to :developer
      t.belongs_to :data_set
      t.belongs_to :status

      t.string :name
      t.integer :gather_task
      t.datetime :distributed_at
      t.datetime :last_status_changed_at
      t.date :last_export
      t.boolean :staging_table_attached, default: false
      t.timestamps
    end
  end
end
