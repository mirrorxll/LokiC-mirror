# frozen_string_literal: true

class CreateRequestedWorkPriority < ActiveRecord::Migration[6.0]
  def change
    create_table :requested_work_priorities do |t|
      t.string :name
      t.timestamps
    end
  end
end
