# frozen_string_literal: true

class AddAdjusterIdToCronTabs < ActiveRecord::Migration[6.0]
  def change
    add_reference :cron_tabs, :adjuster, after: :story_type_id
  end
end
