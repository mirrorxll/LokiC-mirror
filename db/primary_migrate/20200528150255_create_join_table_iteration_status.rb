# frozen_string_literal: true

class CreateJoinTableIterationStatus < ActiveRecord::Migration[6.0]
  def change
    create_join_table :iterations, :statuses do |t|
      t.index %i[iteration_id status_id], unique: true
    end
  end
end
