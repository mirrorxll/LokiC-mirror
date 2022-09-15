class AddCommentToFactoidTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :factoid_types, :comment, :text, after: :original_publish_date
  end
end
