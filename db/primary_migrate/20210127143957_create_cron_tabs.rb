class CreateCronTabs < ActiveRecord::Migration[6.0]
  def change
    create_table :cron_tabs do |t|
      t.belongs_to :story_type

      t.boolean :enabled, default: false
      t.string  :setup
      t.timestamps
    end
  end
end
