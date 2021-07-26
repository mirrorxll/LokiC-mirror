class DropCommentSubtypes < ActiveRecord::Migration[6.0]
  def change
    drop_table :comment_subtypes do |t|
      t.belongs_to :comment

      t.string :name
      t.timestamps
    end
  end
end
