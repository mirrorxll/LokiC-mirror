class ChangeMainIndexInChangeHistory < ActiveRecord::Migration[6.0]
  def change
    remove_index :change_history, name: :index_change_history_on_history_event_id
    remove_index :change_history, name: :index_change_history_on_note_id
    remove_index :change_history, name: :index_change_history_on_history_type_and_history_id
    add_index :change_history, %i[history_type history_id history_event], name: :index_change_history_on_history_type_id_event
  end
end
