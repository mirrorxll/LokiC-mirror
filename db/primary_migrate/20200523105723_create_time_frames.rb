class CreateTimeFrames < ActiveRecord::Migration[6.0]
  def change
    create_table :time_frames do |t|
      t.string :frame
      t.timestamps
    end
  end
end
