# frozen_string_literal: true

class AddStatusToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_reference :accounts, :status, after: :id
  end
end
