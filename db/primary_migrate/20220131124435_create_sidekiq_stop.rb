class CreateSidekiqStop < ActiveRecord::Migration[6.0]
  def change
    create_table :sidekiq_stops do |t|
      t.references :story_type, null: false, foreign_key: true
      t.boolean :cancel

      t.timestamps
    end
  end
end
