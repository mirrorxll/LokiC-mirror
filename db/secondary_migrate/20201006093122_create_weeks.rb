# frozen_string_literal: true

class CreateWeeks < ActiveRecord::Migration[6.0]
  def change
    create_table :weeks do |t|
      t.date :begin
      t.date :end
    end
  end
end
