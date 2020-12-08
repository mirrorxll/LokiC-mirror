# frozen_string_literal: true

class RemoveAccountTypeIdFromAccounts < ActiveRecord::Migration[6.0]
  def change
    Account.all.each do |account|
      account.account_types << AccountType.find(account[:account_type_id])
    end

    remove_column :accounts, :account_type_id
  end
end
