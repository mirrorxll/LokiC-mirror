class AddTimestampsToOutputs < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :outputs, null: true

    long_ago = DateTime.now
    Output.update_all(created_at: long_ago, updated_at: long_ago)

    change_column_null :outputs, :created_at, false
    change_column_null :outputs, :updated_at, false
  end
end
