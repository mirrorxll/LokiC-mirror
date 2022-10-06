# frozen_string_literal: true

class AddUniqIndexToMainAgencies < ActiveRecord::Migration[6.0]
  def change
    add_index :main_agencies, :name, unique: true
  end
end
