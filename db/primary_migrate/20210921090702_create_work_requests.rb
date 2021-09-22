class CreateWorkRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :work_requests do |t|
      t.belongs_to :requester
      t.belongs_to :underwriting_project

      t.string :other_type_of_work, limit: 500
      t.string :other_client_name
      t.string :other_underwriting_project

      t.date :goal_deadline
      t.date :final_deadline

      t.string :budget_of_project
    end
  end
end
