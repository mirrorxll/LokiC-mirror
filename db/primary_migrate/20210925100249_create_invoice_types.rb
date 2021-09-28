# frozen_string_literal: true

class CreateInvoiceTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :invoice_types do |t|
      t.string  :name
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
