# frozen_string_literal: true

class CreateCommentAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_assignments do |t|
      t.belongs_to :comment
      t.belongs_to :account

      t.index %i[comment_id account_id],
              unique: true, name: 'comments_accounts_unique_index'
    end
  end
end
