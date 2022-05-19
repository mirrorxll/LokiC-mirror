# frozen_string_literal: true

class AddAuthTokenToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :auth_token, :string, after: :id, index: { uniq: true }
  end
end
