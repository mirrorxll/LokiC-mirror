class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.belongs_to :story_type

      t.string :body, limit: 15000
      t.timestamps
    end
  end
end
