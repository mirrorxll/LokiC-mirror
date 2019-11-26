# frozen_string_literal: true

class CreateStagingTables < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :staging_tables do |t|
      t.string  :name
      t.text    :columns

      t.belongs_to :story

      t.timestamps
    end
  end
end
