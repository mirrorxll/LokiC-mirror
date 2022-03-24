class AddTopicRefToArticleTypes < ActiveRecord::Migration[6.0]
  def change
    add_reference :article_types, :topic, null: true, foreign_key: true, after: :current_iteration_id
  end
end
