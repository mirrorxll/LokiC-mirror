class CreateSidekiqBreak < ActiveRecord::Migration[6.0]
  def change
    create_table :sidekiq_breaks do |t|
      t.references :breakable, polymorphic: true
      t.boolean :cancel

      t.timestamps
    end
  end
end
