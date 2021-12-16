# frozen_string_literal: true

class CreateTaskTeamWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :task_team_works do |t|
      t.belongs_to :task
      t.belongs_to :creator
      t.boolean    :hours, default: true
      t.decimal    :sum, scale: 7, precision: 9
    end
  end
end
