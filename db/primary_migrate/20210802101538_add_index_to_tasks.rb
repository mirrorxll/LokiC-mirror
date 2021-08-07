# frozen_string_literal: true

class AddIndexToTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :title, :string, limit: 500

    add_index :tasks,
              %i[creator_id title],
              name: 'uniq_creator_title',
              unique: true
  end
end
