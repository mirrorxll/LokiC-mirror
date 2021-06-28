# frozen_string_literal: true

class CreateChangeHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :change_history do |t|
      t.references :history, polymorphic: true
      t.belongs_to :history_event

      t.timestamps
    end
  end
end
