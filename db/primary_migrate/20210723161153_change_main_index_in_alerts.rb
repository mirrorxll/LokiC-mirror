class ChangeMainIndexInAlerts < ActiveRecord::Migration[6.0]
  def change
    remove_index :alerts, name: :index_alerts_on_alert_type_and_alert_id
    remove_index :alerts, name: :index_alerts_on_note_id
    remove_index :alerts, name: :index_alerts_on_subtype_id
    add_index :alerts, %i[alert_type alert_id subtype]
  end
end
