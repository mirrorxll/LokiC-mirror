# frozen_string_literal: true

class CreateAccountsAccountRoles < ActiveRecord::Migration[6.0]
  def change
    create_join_table :accounts, :account_roles do |t|
      t.index %i[account_id account_role_id], unique: true, name: 'index_on_account_account_role'
      t.index %i[account_role_id account_id], unique: true, name: 'index_on_account_role_account'
    end
  end
end
