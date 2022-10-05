class CreateExceptionRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :exception_records do |t|
      t.belongs_to :account

      t.string :name
      t.string :description
      t.string :backtrace
      t.text   :requested_params

      t.timestamps
    end
  end
end
