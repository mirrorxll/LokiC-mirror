# frozen_string_literal: true

class AddCronTabToStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :story_type_iterations, :cron_tab, :boolean,
               default: false, after: :story_type_id
  end
end
