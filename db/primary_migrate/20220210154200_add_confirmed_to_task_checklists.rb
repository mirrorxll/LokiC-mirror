class AddConfirmedToTaskChecklists < ActiveRecord::Migration[6.0]
  def change
    add_column :task_checklists, :confirmed, :boolean, default: false, after: :description
  end
end
