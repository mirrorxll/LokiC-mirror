# frozen_string_literal: true

class AddColumnExistOnPlToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :exist_in_pl, :boolean, default: true, after: :name
  end
end
