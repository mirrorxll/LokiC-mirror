class CreateIndices < ActiveRecord::Migration[6.0]
  def change
    create_table :indices do |t|
      t.belongs_to :staging_table

      t.string :list, limit: 1000
      t.timestamps
    end
  end
end
