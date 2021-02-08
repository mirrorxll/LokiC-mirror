class ChangeSetupColumnSizeForCronTabs < ActiveRecord::Migration[6.0]
  def change
    change_column :cron_tabs, :setup, :string, limit: 2000
  end
end
