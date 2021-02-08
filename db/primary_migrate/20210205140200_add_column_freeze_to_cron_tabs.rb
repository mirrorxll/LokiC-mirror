#frozen_string_literal: true

class AddColumnFreezeToCronTabs < ActiveRecord::Migration[6.0]
  def change
    add_column :cron_tabs,
               :freeze_execution,
               :boolean,
               default: false, after: :story_type_id
  end
end
