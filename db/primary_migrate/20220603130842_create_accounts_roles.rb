class CreateAccountsRoles < ActiveRecord::Migration[6.0]
  def change
    create_join_table :accounts, :roles do |t|
      t.index %i[account_id role_id], unique: true, name: 'index_on_account_role'
      t.index %i[role_id account_id], unique: true, name: 'index_on_role_account'
    end
  end
end
