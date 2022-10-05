class CreateWorkRequestOpportunities < ActiveRecord::Migration[6.0]
  def change
    create_table :work_request_opportunities do |t|
      t.belongs_to :work_request
      t.belongs_to :main_agency
      t.belongs_to :main_opportunity

      t.integer :percent
      t.timestamps
    end
  end
end
