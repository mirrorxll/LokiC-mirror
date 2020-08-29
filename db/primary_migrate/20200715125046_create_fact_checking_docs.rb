class CreateFactCheckingDocs < ActiveRecord::Migration[6.0]
  def change
    create_table :fact_checking_docs do |t|
      t.belongs_to :story_type

      t.text :body, limit: 16_777_215
      t.string :slack_message_ts
      t.timestamps
    end
  end
end
