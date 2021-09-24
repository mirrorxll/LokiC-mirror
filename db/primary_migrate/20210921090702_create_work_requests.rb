class CreateWorkRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :work_requests do |t|
      t.belongs_to :requester
      t.belongs_to :underwriting_project

      t.date :goal_deadline
      t.date :final_deadline

      t.string :budget_of_project
    end
  end
end
