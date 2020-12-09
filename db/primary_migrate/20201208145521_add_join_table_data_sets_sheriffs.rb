# frozen_string_literal: true

class AddJoinTableDataSetsSheriffs < ActiveRecord::Migration[6.0]
  def change
    create_join_table :data_sets, :accounts, table_name: 'data_sets_sheriffs' do |t|
      t.index %i[data_set_id account_id], unique: true
      t.index %i[account_id data_set_id], unique: true
    end
  end
end
