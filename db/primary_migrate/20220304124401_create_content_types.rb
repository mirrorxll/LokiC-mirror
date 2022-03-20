# frozen_string_literal: true

class CreateContentTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :content_types, id: false do |t|
      t.string   :id, limit: 36, primary_key: true
      t.string   :name
      t.datetime :archived_at, index: true
      t.string   :content_group_id, limit: 36
      t.timestamps
    end
  end
end
