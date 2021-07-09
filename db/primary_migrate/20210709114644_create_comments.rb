class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.bigint :commentable_id
      t.string :commentable_type
      t.bigint :subtype_id

      t.string :body, limit: 2000
      t.timestamps
    end

    add_index :comments, %i[commentable_id commentable_type subtype_id],
              name: 'uniq_index_on_comment', unique: true
  end
end
