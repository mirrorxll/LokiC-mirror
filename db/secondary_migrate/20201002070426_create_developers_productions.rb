# frozen_string_literal: true

class CreateDevelopersProductions < ActiveRecord::Migration[6.0]
  def change
    create_table :developers_productions do |t|
      t.belongs_to :developer
      t.belongs_to :iteration

      t.boolean :first_export
      t.datetime :date_export
    end
  end
end
