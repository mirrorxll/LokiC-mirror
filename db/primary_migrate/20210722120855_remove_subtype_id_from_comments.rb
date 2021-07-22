# frozen_string_literal: true

class RemoveSubtypeIdFromComments < ActiveRecord::Migration[6.0]
  def change
    remove_index :comments, name: :uniq_index_on_comment
    remove_column :comments, :subtype_id
    add_index :comments, %i[commentable_type commentable_id]
  end
end
