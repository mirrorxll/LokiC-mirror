# frozen_string_literal: true

class CreateInvoiceFrequencies < ActiveRecord::Migration[6.0]
  def change
    create_table :invoice_frequencies do |t|
      t.string  :name
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
