class CreateDataSetPhotoBuckets < ActiveRecord::Migration[6.0]
  def change
    create_table :data_set_photo_buckets do |t|
      t.belongs_to :data_set
      t.belongs_to :photo_bucket
    end
  end
end
