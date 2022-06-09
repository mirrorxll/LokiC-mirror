class CreateAccountsBranchesAccessLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts_branches_access_levels do |t|
      t.belongs_to :account, index: false
      t.belongs_to :branch, index: false
      t.belongs_to :access_level, index: false

      t.boolean :enabled, default: false
    end

    add_index :accounts_branches_access_levels,
              :account_id, name: 'index_on_account_id'
  end
end
