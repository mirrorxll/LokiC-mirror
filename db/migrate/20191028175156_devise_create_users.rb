# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :users do |t|
      t.string    :email,                     null: false
      t.string    :encrypted_password,        null: false
      t.string    :reset_password_token
      t.datetime  :reset_password_sent_at
      t.string    :first_name,                null: false
      t.string    :last_name,                 null: false
      t.datetime  :remember_created_at

      t.belongs_to :account_type

      t.timestamps
    end

    add_index :users, :email,                 unique: true
    add_index :users, :reset_password_token,  unique: true
    add_index :users, %i[first_name last_name]
  end
end
