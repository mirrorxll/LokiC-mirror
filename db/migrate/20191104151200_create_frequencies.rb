# frozen_string_literal: true

class CreateFrequencies < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :frequencies do |t|
      t.string :name

      t.timestamps
    end
  end
end
