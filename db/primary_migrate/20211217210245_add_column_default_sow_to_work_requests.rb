class AddColumnDefaultSowToWorkRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :work_requests, :default_sow, :boolean,
               default: false, after: :priority_id
  end
end
