# frozen_string_literal: true

class CreateChangeHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :change_history do |t|
      t.references :historyable, polymorphic: true
      t.belongs_to :history_event

      t.string :notes, limit: 1000
      t.timestamps
    end
  end
end
