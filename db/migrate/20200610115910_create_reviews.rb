class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.string :report_type
      t.text :table

      t.timestamps
    end
  end
end
