class CreateColumns < ActiveRecord::Migration[6.0]
  def change
    create_table :columns do |t|
      t.belongs_to :staging_table

      t.string :list, limit: 10_000
      t.timestamps
    end
  end
end
