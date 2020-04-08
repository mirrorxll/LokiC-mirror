class CreateSlackAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_accounts do |t|
      t.belongs_to :account

      t.string :identifier
      t.string :user_name
      t.string :deleted
      t.timestamps
    end

    add_index :slack_accounts, :identifier, unique: true
  end
end
