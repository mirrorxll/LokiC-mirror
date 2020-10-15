# frozen_string_literal: true

class CreateAssembleds < ActiveRecord::Migration[6.0]
  def change
    create_table :assembleds do |t|
      t.date :date
      t.string :dept
      t.string :name
      t.string :updated_description
      t.string :oppourtunity_name
      t.string :oppourtunity_id
      t.string :old_product_name
      t.string :sf_product_id
      t.string :client_name
      t.string :account_name
      t.string :hours
      t.string :employment_classification
    end
  end
end
