class AddMaxTimeFrameToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :max_time_frame, :string, after: :last_export
  end
end
