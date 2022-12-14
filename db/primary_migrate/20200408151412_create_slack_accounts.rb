class CreateSlackAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_accounts do |t|
      t.belongs_to :account

      t.string  :identifier
      t.string  :user_name
      t.string  :display_name
      t.boolean :deleted
      t.timestamps
    end

    add_index :slack_accounts, :identifier, unique: true
  end
end
