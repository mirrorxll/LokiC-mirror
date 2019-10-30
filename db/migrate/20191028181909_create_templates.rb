# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :templates do |t|
      t.text :text

      t.belongs_to :story

      t.timestamps
    end
  end
end
