class ChangeMainIndexInComments < ActiveRecord::Migration[6.0]
  def change
    remove_index :comments, name: :index_comments_on_commentable_type_and_commentable_id
    add_index :comments, %i[commentable_type commentable_id subtype], name: :index_comments_on_type_id_subtype
  end
end
