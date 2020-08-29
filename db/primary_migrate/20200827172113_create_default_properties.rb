class CreateDefaultProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :default_properties do |t|
      t.belongs_to :data_set
      t.belongs_to :photo_bucket
      t.string :client_tag
    end
  end
end
