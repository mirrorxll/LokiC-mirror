class AddCheckUpdatesToReminders < ActiveRecord::Migration[6.0]
  def change
    add_column :reminders, :check_updates, :boolean, default: false, after: :story_type_id
  end
end
