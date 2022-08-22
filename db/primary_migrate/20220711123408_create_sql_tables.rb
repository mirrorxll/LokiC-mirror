# frozen_string_literal: true

class CreateSqlTables < ActiveRecord::Migration[6.0]
  def change
    create_table :sql_tables do |t|
      t.belongs_to :schema

      t.string :name
      t.text   :columns
      t.bigint :total_records
      t.timestamps
    end
  end
end
