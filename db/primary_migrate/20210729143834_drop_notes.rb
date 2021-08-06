# frozen_string_literal: true

class DropNotes < ActiveRecord::Migration[6.0]
  def change
    drop_table :notes do |t|
      t.string :md5hash
      t.string :note, limit: 2000
      t.timestamps
    end
  end
end
