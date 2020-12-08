# frozen_string_literal: true

class CreateJoinTableAccountsAccountTypes < ActiveRecord::Migration[6.0]
  def change
    create_join_table :accounts, :account_types do |t|
      t.index %i[account_id account_type_id], unique: true
      t.index %i[account_type_id account_id], unique: true
    end
  end
end
