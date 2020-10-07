# frozen_string_literal: true

class CreateWeeks < ActiveRecord::Migration[6.0]
  def change
    create_table :weeks do |t|
      t.date :begin_week
      t.date :end_week
    end
  end
end
