class AddColumnsToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :max_time_frame, :string, after: :last_export
    add_column :story_types, :next_export, :date, after: :last_export
  end
end
