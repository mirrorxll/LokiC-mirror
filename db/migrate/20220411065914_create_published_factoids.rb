class CreatePublishedFactoids < ActiveRecord::Migration[6.0]
  def change
    create_table :published_factoids do |t|
      t.belongs_to :developer, null: false, foreign_key: true
      t.belongs_to :article_type, null: false, foreign_key: true
      t.belongs_to :iteration, null: false, foreign_key: true

      t.date    :original_publish_date
      t.integer :count_factoids

      t.timestamps
    end
  end
end
