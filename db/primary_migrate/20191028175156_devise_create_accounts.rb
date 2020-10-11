# frozen_string_literal: true

class DeviseCreateAccounts < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :accounts do |t|
      t.belongs_to :account_type

      t.string    :email,                     null: false
      t.string    :encrypted_password,        null: false
      t.string    :reset_password_token
      t.datetime  :reset_password_sent_at
      t.string    :first_name,                null: false
      t.string    :last_name,                 null: false
      t.boolean   :upwork,
      t.datetime  :remember_created_at
      t.timestamps
    end

    add_index :accounts, :email,                 unique: true
    add_index :accounts, :reset_password_token,  unique: true
    add_index :accounts, %i[first_name last_name]
  end
end
