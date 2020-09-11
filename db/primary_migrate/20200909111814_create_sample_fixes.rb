class CreateSampleFixes < ActiveRecord::Migration[6.0]
  def change
    create_table :sample_fixes do |t|
      t.belongs_to :sample

      t.string     :description
      t.timestamps
    end
  end
end
