class AddShowColumnToSamples < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :show, :boolean, default: false, after: :sampled
    add_index :samples, %i[story_type_id show]
    add_index :samples, %i[iteration_id show]
    add_index :samples, "pl_#{PL_TARGET}_story_id", unique: true
  end
end
