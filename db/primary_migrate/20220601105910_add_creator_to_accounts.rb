# frozen_string_literal: true

class AddCreatorToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_reference :accounts, :creator, after: :id
  end
end
