# frozen_string_literal: true

class CreateWorkRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :work_requests do |t|
      t.belongs_to :requester
      t.belongs_to :underwriting_project
      t.belongs_to :invoice_type
      t.belongs_to :invoice_frequency
      t.belongs_to :priority

      t.string  :sow
      t.date    :expected_first_invoice
      t.date    :expected_final_invoice
      t.date    :goal_deadline
      t.date    :final_deadline
      t.string  :budget_of_project
      t.date    :last_invoice
      t.boolean :billed_for_entire_project?
      t.integer :r_val
      t.integer :f_val
    end
  end
end
