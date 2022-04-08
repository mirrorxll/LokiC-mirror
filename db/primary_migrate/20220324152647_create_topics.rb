class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.string :external_lp_id, length: 36
      t.string :description
      t.timestamp :deleted_at

      t.timestamps
    end

    create_table :kinds do |t|
      t.references :parent_kind, foreign_key: { to_table: :kinds }
      t.string :name

      t.timestamps
    end

    create_table :kinds_topics, id: false do |t|
      t.belongs_to :kind
      t.belongs_to :topic
    end
  end
end
