# frozen_string_literal: true

class AddOrderToAccountRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :account_roles, :order, :integer, after: :name
  end
end
