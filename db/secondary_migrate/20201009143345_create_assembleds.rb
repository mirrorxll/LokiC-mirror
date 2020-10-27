# frozen_string_literal: true

class CreateAssembleds < ActiveRecord::Migration[6.0]
  def change
    create_table :assembleds do |t|
      t.belongs_to :developer
      t.belongs_to :week

      t.string   :dept
      t.string   :updated_description
      t.string   :oppourtunity_name
      t.string   :oppourtunity_id
      t.string   :old_product_name
      t.string   :sf_product_id
      t.string   :client_name
      t.string   :account_name
      t.decimal  :hours, scale: 2, precision: 4
    end
  end
end
