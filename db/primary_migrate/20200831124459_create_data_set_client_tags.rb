class CreateDataSetClientTags < ActiveRecord::Migration[6.0]
  def change
    create_table :data_set_client_tags do |t|
      t.belongs_to :data_set
      t.belongs_to :client
      t.belongs_to :tag
    end
  end
end
